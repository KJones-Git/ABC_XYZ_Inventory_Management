-- Import and Check Dataset
SELECT *
FROM abc_xyz_dataset
LIMIT 100;

-- Create Staging Table

CREATE TABLE abc_staging
LIKE abc_xyz_dataset;

INSERT abc_staging
SELECT *
FROM abc_xyz_dataset;

SELECT * 
FROM abc_staging;

SELECT COUNT(*) AS total_rows
FROM abc_staging;

-- Create ABC Classification

ALTER TABLE abc_staging
ADD COLUMN abc_class CHAR(1);

WITH sales_ranked AS (
    SELECT
        Item_ID,
        Total_Sales_Value,
        SUM(Total_Sales_Value) OVER () AS total_sales,
        SUM(Total_Sales_Value) OVER (ORDER BY Total_Sales_Value DESC) AS cumulative_sales
    FROM abc_staging
),
sales_with_percentile AS (
    SELECT
        Item_ID,
        cumulative_sales * 1.0 / total_sales AS sales_percent
    FROM sales_ranked
)
UPDATE abc_staging s
JOIN sales_with_percentile p ON s.Item_ID = p.Item_ID
SET s.abc_class = 
    CASE
        WHEN p.sales_percent < 0.4 THEN 'A'
        WHEN p.sales_percent < 0.8 THEN 'B'
        ELSE 'C'
    END;

SELECT *
FROM abc_staging
ORDER BY abc_class, Total_Sales_Value DESC;

-- Count the Different Classifications
SELECT
  abc_class,
  COUNT(*) AS product_count
FROM abc_staging
GROUP BY abc_class
ORDER BY abc_class;

-- Create the XYZ Classification

-- Find Standard Deviation for each Product

ALTER TABLE abc_staging
ADD COLUMN StanDev DECIMAL(10, 2);

ALTER TABLE abc_staging
ADD COLUMN avg_demand DECIMAL(10, 2);

UPDATE abc_staging
SET avg_demand = (
    Jan_Demand + Feb_Demand + Mar_Demand + Apr_Demand + May_Demand + Jun_Demand +
    Jul_Demand + Aug_Demand + Sep_Demand + Oct_Demand + Nov_Demand + Dec_Demand
) / 12.0;

UPDATE abc_staging
SET StanDev = SQRT(
    (
        POW(Jan_Demand - avg_demand, 2) +
        POW(Feb_Demand - avg_demand, 2) +
        POW(Mar_Demand - avg_demand, 2) +
        POW(Apr_Demand - avg_demand, 2) +
        POW(May_Demand - avg_demand, 2) +
        POW(Jun_Demand - avg_demand, 2) +
        POW(Jul_Demand - avg_demand, 2) +
        POW(Aug_Demand - avg_demand, 2) +
        POW(Sep_Demand - avg_demand, 2) +
        POW(Oct_Demand - avg_demand, 2) +
        POW(Nov_Demand - avg_demand, 2) +
        POW(Dec_Demand - avg_demand, 2)
    ) / 12
);

ALTER TABLE abc_staging
ADD COLUMN StanDev DECIMAL(10, 2);

-- Find the Coefficient Variation

ALTER TABLE abc_staging
ADD COLUMN Coefficient_Variation DECIMAL(10, 4);

UPDATE abc_staging
SET Coefficient_Variation = 
    CASE 
        WHEN avg_demand = 0 THEN NULL
        ELSE StanDev / avg_demand
    END;

UPDATE abc_staging
SET Coefficient_Variation = 
    CASE 
        WHEN avg_demand = 0 THEN NULL
        ELSE ROUND((StanDev / avg_demand) * 100, 2)
    END;

-- Give each product an XYZ Classification

ALTER TABLE abc_staging
ADD COLUMN XYZ_classification CHAR(1);

UPDATE abc_staging
SET XYZ_classification = CASE
    WHEN Coefficient_Variation < 10 THEN 'X'
    WHEN Coefficient_Variation >= 10 AND Coefficient_Variation < 25 THEN 'Y'
    WHEN Coefficient_Variation >= 25 THEN 'Z'
    ELSE NULL
END;

-- Create ABC_XYZ Classification

ALTER TABLE abc_staging
ADD COLUMN `ABC_XYZ_Classification` VARCHAR(2);

UPDATE abc_staging
SET `ABC_XYZ_Classification` = CONCAT(abc_class, XYZ_classification);

-- Analyze the Finished Dataset

-- First 10 Rows of Dataset

SELECT Item_ID, Item_Name, Category, Total_Sales_Value, abc_class, StanDev, avg_demand, Coefficient_Variation, XYZ_classification, ABC_XYZ_Classification 
FROM  abc_staging
LIMIT 10;

-- Count of each final classification

SELECT
  ABC_XYZ_Classification,
  COUNT(*) AS product_count
FROM abc_staging
GROUP BY ABC_XYZ_Classification
ORDER BY ABC_XYZ_Classification;

-- Percent of products that fall into each ABC class

SELECT 
  abc_class,
  COUNT(*) AS product_count,
  CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM abc_staging), 1), '%') AS percentage_of_total
FROM abc_staging
GROUP BY abc_class
ORDER BY abc_class;

-- The XYZ classifications of C Products

SELECT 
  XYZ_classification,
  COUNT(*) AS product_count,
  CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM abc_staging WHERE abc_class = 'C'), 2), '%') AS percentage_of_C_products
FROM abc_staging
WHERE abc_class = 'C'
GROUP BY XYZ_classification
ORDER BY XYZ_classification;

-- Create a Matrix Visualization

SELECT
  abc_class AS ' ',
  SUM(CASE WHEN XYZ_classification = 'X' THEN 1 ELSE 0 END) AS 'X',
  SUM(CASE WHEN XYZ_classification = 'Y' THEN 1 ELSE 0 END) AS 'Y',
  SUM(CASE WHEN XYZ_classification = 'Z' THEN 1 ELSE 0 END) AS 'Z'
FROM abc_staging
GROUP BY abc_class
ORDER BY abc_class;










