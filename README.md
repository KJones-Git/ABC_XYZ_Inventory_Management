# 📦 ABC XYZ Product Classification Analysis

This project performs a detailed **ABC-XYZ Analysis** on a product demand dataset to classify items by both their **revenue contribution** and **demand variability**.  

The goal is to help prioritize inventory management, improve forecasting accuracy, and identify critical SKUs for the 1000 products listed in the dataset.

![](https://github.com/KJones-Git/ABC_XYZ_Inventory_Management/blob/693212885357285c1f8919c089d026375e3a5aea/images/abc_xyz_chart.png)

---

## 📊 Project Overview

- **Dataset**: abc_xyz_dataset.csv
- **Database**: MySQL 8.0+
- **Key Objectives**:
  - Perform **ABC classification** based on cumulative revenue.
  - Perform **XYZ classification** based on coefficient of variation in monthly demand.
  - Create a combined **ABC-XYZ Classification** to support inventory and business decisions.

---

## 🛠️ Process Workflow

1. **Data Preparation**:
   - Imported monthly demand and sales data into MySQL (`abc_staging` table).
   - Cleaned and standardized fields for analysis.

2. **ABC Classification**:
   - `A`: Top 40% of cumulative sales revenue.
   - `B`: Next 40%.
   - `C`: Remaining 20%.
   - Stored results in a new column `abc_class`.

3. **XYZ Classification**:
   - Calculated **average monthly demand** and **standard deviation** for each product.
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
## Final Dataset Example


---

## 📈 Example Outputs

### ABCXYZ Matrix

| ABC XYZ Classification | X  | Y  | Z  |
|--------------------|----|----|----|
| A                  | 14  | 0  | 0  |
| B                  | 52  | 18 | 3 |
| C                  | 590  | 182 | 141 |

### ABC Classification Counts

| ABC | Product Count  | Percentage of Total |
|--------------------|----|----|
| A                  | 14  | 1.4%  |
| B                  | 73  | 7.3% |
| C                  | 913  | 91.3% | 

### C Products Analysis

| XYZ Classification | Product Count  | Percentage of C Products |
|--------------------|----|----|
| X                 | 590  | 64.62%  |
| Y                 | 182  | 19.93% |
| Z                  | 141  | 15.44% | 


---

## ✨ Technologies Used

- **MySQL 8.0+** (Data storage, transformations, analysis)
- **Python (optional)** (Data previews, visualizations)
- **Excel / Tableau** (for final matrix formatting and charts)

---

## 📂 Project Structure

```plaintext
/data
  - abc_xyz_dataset.csv
  - abc_xyz_classification_counts.csv

/sql
  - abc_classification.sql
  - xyz_classification.sql
  - abc_xyz_matrix.sql

/outputs
  - final_export.csv
  - abc_xyz_summary_chart.png

README.md
```

---

## 🚀 Future Enhancements

- Automate matrix generation and export using Python scripts.
- Build interactive dashboards (e.g., Tableau, Power BI).
- Add forecasting models for XYZ product categories.

---

## 👌 Acknowledgments

Special thanks to open-source SQL and analytics communities for reference techniques and optimization tips!
