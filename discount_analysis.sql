USE SuperstoreDB;

-- 1. Furniture profit margin by discount band
SELECT
    CASE
        WHEN Discount = 0 THEN '1. No discount'
        WHEN Discount <= 0.20 THEN '2. Up to 20%'
        WHEN Discount <= 0.40 THEN '3. 21-40%'
        ELSE '4. Above 40%'
    END AS Discount_Band,
    COUNT(*) AS Order_Lines,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Pct
FROM dbo.orders
WHERE Category = 'Furniture'
GROUP BY
    CASE
        WHEN Discount = 0 THEN '1. No discount'
        WHEN Discount <= 0.20 THEN '2. Up to 20%'
        WHEN Discount <= 0.40 THEN '3. 21-40%'
        ELSE '4. Above 40%'
    END
ORDER BY Discount_Band;

-- 2. Furniture lines with discount over 20%: count and total loss
SELECT
    COUNT(*) AS Order_Lines,
    SUM(Profit) AS Total_Profit
FROM dbo.orders
WHERE Category = 'Furniture' AND Discount > 0.20;

-- 3. Same lines by sub-category
SELECT
    Sub_Category,
    COUNT(*) AS Order_Lines,
    SUM(Profit) AS Total_Profit
FROM dbo.orders
WHERE Category = 'Furniture' AND Discount > 0.20
GROUP BY Sub_Category
ORDER BY Total_Profit;

-- Sales and profit margin by customer segment
USE SuperstoreDB;
GO

SELECT
    Segment,
    CAST(SUM(Sales) AS DECIMAL(12,0)) AS Total_Sales,
    CAST(SUM(Profit) AS DECIMAL(12,0)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / SUM(Sales) AS DECIMAL(5,1)) AS Profit_Margin_Pct,
    CAST(100.0 * SUM(Sales) / SUM(SUM(Sales)) OVER () AS DECIMAL(5,1)) AS Pct_of_Total_Sales
FROM dbo.orders
GROUP BY Segment
ORDER BY Total_Sales DESC;
GO

-- Top 10 customers by sales (the #1 customer, Sean Miller, loses money)
SELECT TOP 10
    Customer_Name,
    Segment,
    CAST(SUM(Sales) AS DECIMAL(12,0)) AS Total_Sales,
    CAST(SUM(Profit) AS DECIMAL(12,0)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS DECIMAL(5,1)) AS Profit_Margin_Pct
FROM dbo.orders
GROUP BY Customer_Name, Segment
ORDER BY Total_Sales DESC;
GO

-- Why Sean Miller loses money: Machines with a 50% average discount
SELECT
    Category,
    Sub_Category,
    CAST(SUM(Sales) AS DECIMAL(12,0)) AS Total_Sales,
    CAST(SUM(Profit) AS DECIMAL(12,0)) AS Total_Profit,
    CAST(100.0 * AVG(Discount) AS DECIMAL(5,1)) AS Avg_Discount_Pct
FROM dbo.orders
WHERE Customer_Name = 'Sean Miller'
GROUP BY Category, Sub_Category
ORDER BY Total_Profit ASC;
GO

-- Top 10 customers by profit (the most profitable customers all have margins above 34%)
USE SuperstoreDB;
GO

SELECT TOP 10
    Customer_Name,
    Segment,
    CAST(SUM(Sales) AS DECIMAL(12,0)) AS Total_Sales,
    CAST(SUM(Profit) AS DECIMAL(12,0)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS DECIMAL(5,1)) AS Profit_Margin_Pct
FROM dbo.orders
GROUP BY Customer_Name, Segment
ORDER BY Total_Profit DESC;
GO

-- Sales, profit and average discount by region (Central discounts most and earns the least)
SELECT
    Region,
    CAST(SUM(Sales) AS DECIMAL(12,0)) AS Total_Sales,
    CAST(SUM(Profit) AS DECIMAL(12,0)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS DECIMAL(5,1)) AS Profit_Margin_Pct,
    CAST(100.0 * AVG(Discount) AS DECIMAL(5,1)) AS Avg_Discount_Pct
FROM dbo.orders
GROUP BY Region
ORDER BY Total_Sales DESC;
GO

-- Check: margin by Furniture sub-category at 0% discount
-- Tables 18.5%, Bookcases 19.0%, Chairs 24.1%, Furnishings 27.4%
-- Shows these products are profitable at full price, so the losses come from discounting
SELECT Sub_Category,
       COUNT(*) AS Order_Lines,
       ROUND(SUM(Profit) / SUM(Sales) * 100, 1) AS Profit_Margin_Pct
FROM dbo.orders
WHERE Category = 'Furniture' AND Discount = 0
GROUP BY Sub_Category
ORDER BY Profit_Margin_Pct;
