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