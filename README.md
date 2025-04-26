# 📦 ABC XYZ Product Classification Analysis

<p align="center">
  <img src="https://github.com/KJones-Git/ABC_XYZ_Inventory_Management/blob/693212885357285c1f8919c089d026375e3a5aea/images/abc_xyz_chart.png?raw=true" width="500">
</p>

This project delivers a comprehensive **ABC-XYZ Analysis** on a product inventory dataset, classifying items based on both their **revenue contribution** and **demand variability**.

The primary objective is to support **inventory optimization**, **enhance forecasting accuracy**, and **identify critical SKUs** across a portfolio of **1,000 products**.

Analysis was conducted using both **SQL** and **Microsoft Excel** to highlight the advantages of each tool for supply chain and operational planning.  

All relevant files and scripts are available below:

- 📄 [SQL Queries](https://github.com/KJones-Git/ABC_XYZ_Inventory_Management/blob/2e664169ed8c9906c93b30dbe31fc6ed21300869/ABC_XYZ_staging.sql)
- 📈 [Excel Workbook](https://github.com/KJones-Git/ABC_XYZ_Inventory_Management/blob/2e664169ed8c9906c93b30dbe31fc6ed21300869/Excel_ABC_XYZ_Test.xlsx)

## 📚 Table of Contents

### 🔍 Overview
- [Project Overview](#project-overview)
- [Process Workflow](#process-workflow)

### 🧠 SQL Logic
- [SQL Code](#sql-code)
  - [ABC Classification](#abc-classification)
  - [Average Demand Calculation](#average-demand-calculation)
  - [Standard Deviation Calculation](#standard-deviation-calculation)
  - [Coefficient Variation Calculation](#coefficient-variation-calculation)
  - [XYZ Classification](#xyz-classification)
  - [Final ABC XYZ Classification](#final-abc-xyz-classification)

### 📦 Results
- [Final Dataset](#final-dataset)
- [Outputs and Analysis](#outputs-and-analysis)

### 🛠️ Tools & Structure
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)

### 🚀 Future & Thanks
- [Future Enhancements](#future-enhancements)
- [Acknowledgments](#acknowledgments)

---

## Project Overview

- **Dataset**: abc_xyz_dataset.csv
- **Database**: MySQL 8.0+
- **Key Objectives**:
  - Perform **ABC classification** based on cumulative revenue.
  - Perform **XYZ classification** based on coefficient of variation in monthly demand.
  - Create a combined **ABC-XYZ Classification** to support inventory and business decisions.

---

## Process Workflow

1. **Data Preparation**:
   - Imported monthly demand and sales data into MySQL (`abc_staging` table).
   - Cleaned and standardized fields for analysis.

2. **ABC Classification**:
   - `A`: Top 40% of cumulative sales revenue.
   - `B`: Next 40%.
   - `C`: Remaining 20%.
   - Stored results in a new column `abc_class`.
  

3. **XYZ Classification**:
   - Calculated **standard deviation** for each product.
   - Calculated **average monthly demand** for each product.
   - Derived **Coefficient of Variation (CV)**.
   - Classified products:
     - `X`: CV < 10%
     - `Y`: 10% ≤ CV < 25%
     - `Z`: CV ≥ 25%
   - Stored results in a new column `XYZ_classification`.

4. **ABC-XYZ Combined Classification**:
   - Merged `abc_class` and `XYZ_classification` into a final column `ABC_XYZ_Classification` (e.g., `AX`, `BY`, `CZ`).

5. **Matrix Generation**:
   - Created a pivot matrix showing the count of products across ABC and XYZ classifications.

6. **Exports**:
   - Exported classification results into CSV files for reporting and visualization.

---
## SQL Code

### **ABC Classification**
 ```sql
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
```

### **Average Demand Calculation**
```sql
ALTER TABLE abc_staging
ADD COLUMN avg_demand DECIMAL(10, 2);

UPDATE abc_staging
SET avg_demand = (
    Jan_Demand + Feb_Demand + Mar_Demand + Apr_Demand + May_Demand + Jun_Demand +
    Jul_Demand + Aug_Demand + Sep_Demand + Oct_Demand + Nov_Demand + Dec_Demand
) / 12.0;
```
### **Standard Deviation Calculation**
  ```sql
ALTER TABLE abc_staging
ADD COLUMN StanDev DECIMAL(10, 2);

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
```
### **Coefficient Variation Calculation**
```sql
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
```

### **XYZ Classification**
```sql
ALTER TABLE abc_staging
ADD COLUMN XYZ_classification CHAR(1);

UPDATE abc_staging
SET XYZ_classification = CASE
    WHEN Coefficient_Variation < 10 THEN 'X'
    WHEN Coefficient_Variation >= 10 AND Coefficient_Variation < 25 THEN 'Y'
    WHEN Coefficient_Variation >= 25 THEN 'Z'
    ELSE NULL
END;
```

### **Final ABC XYZ Classification**
```sql
ALTER TABLE abc_staging
ADD COLUMN `ABC_XYZ_Classification` VARCHAR(2);

UPDATE abc_staging
SET `ABC_XYZ_Classification` = CONCAT(abc_class, XYZ_classification);
```
---

## Final Dataset

![](https://github.com/KJones-Git/ABC_XYZ_Inventory_Management/blob/2e664169ed8c9906c93b30dbe31fc6ed21300869/images/final_limit10_V2.png)

---

## Outputs and Analysis

### ABC XYZ Matrix

| ABC XYZ Classification | X  | Y  | Z  |
|--------------------|----|----|----|
| A                  | 14  | 0  | 0  |
| B                  | 52  | 18 | 3 |
| C                  | 590  | 182 | 141 |

All high-sales products (**A**) exhibit a highly stable demand pattern (**X**), suggesting that the company can effectively manage these items without maintaining excess inventory for variability.
In contrast, the majority of products with unstable demand (**Z**) are concentrated in the lower sales category (**C**), making it more manageable to carry additional inventory for these items without significantly impacting overall inventory costs.

### ABC Classification Counts

| ABC | Product Count  | Percentage of Total |
|--------------------|----|----|
| A                  | 14  | 1.4%  |
| B                  | 73  | 7.3% |
| C                  | 913  | 91.3% | 

This analysis highlights a classic long-tail distribution: approximately 40% of total revenue is generated by just 1.4% of products.
Conversely, more than 90% of the product portfolio contributes only to the bottom 20% of sales, illustrating the presence of a long tail where a large number of low-volume products have minimal impact on overall financial performance.

Strategically, this concentration suggests that focusing efforts on a small core set of high-performing SKUs could yield the greatest return, while carefully managing or rationalizing the long tail can help optimize operational efficiency and reduce inventory costs.


### C Products Analysis

| XYZ Classification | Product Count  | Percentage of C Products |
|--------------------|----|----|
| X                 | 590  | 64.62%  |
| Y                 | 182  | 19.93% |
| Z                  | 141  | 15.44% | 

Among products classified as C (lower sales contribution), a majority (65%) demonstrated stable demand patterns (X classification).
This indicates that while these products have lower revenue impact, their predictable demand makes them relatively low-risk to manage.
Additionally, 20% of C products fell into the moderate variability category (Y), and only 15% exhibited highly unstable demand patterns (Z), suggesting that most C-class items could be efficiently maintained with minimal safety stock adjustments.

---

## Technologies Used

- **MySQL 8.0+** (Data storage, transformations, analysis)
- **Excel** (for final matrix formatting and charts)

---

## Project Structure

```plaintext
/data
  - abc_xyz_dataset.csv

/sql
  - ABC_XYZ_staging.sql

/excel
  - Excel_ABC_XYZ_Test.xlsx

/outputs
  - abc_staged_dataset.csv

README.md
```

---

## Future Enhancements

- Automate matrix generation and export using Python scripts.
- Build interactive dashboards (e.g., Tableau, Power BI).
- Add forecasting models for XYZ product categories.

---

## Acknowledgments

Special thanks to open-source SQL and analytics communities for reference techniques and optimization tips!
