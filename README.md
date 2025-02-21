# CUD-Psych-Analysis
SQL-based analysis of the association between Cannabis Use Disorder (CUD) and psychological disorders using EHR data.
# CUD & Psychiatric Disorder Analysis Using SQL

## 📌 Project Overview
This project explores the association between **Cannabis Use Disorder (CUD)** and **psychological disorders (Anxiety, Depression, Schizophrenia)** using **Electronic Health Records (EHR) data**. The analysis is performed using **SQL** in **Snowflake**.

## 📂 Files in This Repository
- **`cud_psych_analysis.sql`** → SQL queries to extract insights from EHR data.

## 🔍 Analysis Breakdown
1. **First-time patients** in the dataset.
2. **Patients with CUD** (with and without psychiatric disorders).
3. **Patients without CUD** (who stayed for 6+ months).
4. **Breakdown by disorder type** (Depression, Anxiety, Schizophrenia).
5. **Validation checks to ensure data accuracy**.

## 🚀 How to Use
1. Load the **SQL file** into Snowflake or your database.
2. Run the queries in order to extract insights.
3. Modify filters (`F12%`, `F32%`, `F41%`, `F20%`) to adjust for different ICD-10 codes.

## 📝 Future Enhancements
- Adding **data visualization** (e.g., Tableau, Python Matplotlib).
- Extending analysis to **longitudinal trends**.
- Exploring **causal relationships using statistical models**.

## 💡 Contact
For any questions, reach out at **your.email@example.com** or [LinkedIn](https://linkedin.com/in/YOURUSERNAME).

---

🚀 **Don't forget to commit this file** after saving it!  
You can upload it via GitHub UI or use:

```bash
git add README.md
git commit -m "Added README file"
git push origin main
