<div align="center">

# Petroleum Production Surveillance & PTA Screening
### Volve daily production ingestion and shut-in build-up screening in MySQL 8.0+

[![Database](https://img.shields.io/badge/Database-MySQL_8.0%2B-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](#)
[![Domain](https://img.shields.io/badge/Domain-Petroleum_Data_Engineering-0F766E?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

</div>

## 👋 Welcome!

This repository documents a MySQL workflow for daily Volve production surveillance and candidate shut-in build-up screening.

This repository contains an end-to-end **MySQL 8.0+** workflow for North Sea Volve production surveillance: structured table creation, CSV ingestion with `NULL` normalization, batch logging, and shut-in build-up candidate screening with CTEs and window functions.

Feel free to explore the SQL scripts, clone the repository, and review the workflows. If you have any questions, feedback, or collaboration opportunities, reach out anytime!

---

## 📖 Executive Summary

The completed workflow is:
1. **Volve Production Surveillance & Shut-In Build-Up Screening**: Uses daily North Sea Volve records to identify candidate shut-in pressure windows for first-pass PTA screening.

> **Note on MySQL 8.0+ & macOS Workflow:**  
> The scripts target **MySQL 8.0+** and MySQL Workbench on macOS. The ingestion workflow uses `local_infile`, `NULLIF(TRIM(...), '')`, and a temporary `tmp_log` table for batch execution details.

> **Data source:** The Volve CSV data is available from [Kaggle](https://www.kaggle.com/code/lordkun/volve-production-with-ml/input). The CSV files are not included in this repository. Download `volve_daily_production_all_rows_clean.csv` and `volve_monthly_production_all_rows_clean.csv`, then replace the placeholder paths in the ingestion script with their absolute local paths.
---

## 🏗️ Workflow Architecture

The repository separates table setup and bulk ingestion from the shut-in screening query so each step is straightforward to inspect:

```text
Cleaned daily Volve CSVs
    -> MySQL 8.0+ tables and bulk load
    -> NULL normalization and batch logging
    -> shut-in state timeline
    -> candidate pressure windows for PTA screening
```

## Screening assumptions and interpretation

- The shut-in flag is a project-specific heuristic: oil rate below `5.0` or zero choke opening. Confirm source units and missing-value meaning before using this threshold. The current `COALESCE(..., 0)` logic treats missing rate or choke values as zero.
- Event grouping uses the full daily state timeline and starts a new event after a non-shut-in state or a gap longer than one calendar day.
- `duration_days` is `DATEDIFF` between the first and last pressure-bearing shut-in observations. A value of `1` means the dates differ by one calendar day; it is not a row count or a guarantee of uninterrupted measurements.
- `pressure_range` is the maximum minus minimum observed pressure in the screened window. It is not a chronological pressure change and does not estimate reservoir pressure ($p^*$), permeability, or skin. Those require dedicated time-stepped PTA analysis.
- Results depend on the imported CSV run. No row counts, event totals, or screening yields are published here without a verified run and confirmed units.

## 🛠️ Tech Stack & Prerequisites
Database Engine: MySQL 8.0+

Database Client: MySQL Workbench (macOS)

Querying & Analytics: SQL (CTEs, Window Functions `LAG()` and `SUM() OVER()`, `NULLIF`, Aggregations)

Version Control: Git & GitHub

## 📂 Repository Structure
SQL-Petroleum-surveillance-completion/
├── LICENSE
├── README.md
├── Project 1 volve_production_shut_in_surveillance/
│   ├── Analytics/
│   │   └── isolate_shut_in_buildup_events.sql
│   └── ddl_and_ingestion/
│       └── create_and_load_volve_daily.sql
└── data/
    └── .gitkeep

## 🌟 About the Author
Hi! I am Abdirahman Osman Siyad, a Petroleum Engineer & Data Analyst based in New Cairo, Cairo, Egypt, holding a B.E. in Petroleum Engineering from NED University of Engineering & Technology and PEC registration (PETGAS/004551).
I combine upstream petroleum engineering experience (including SSGC gas transmission and hydraulic fracturing/reservoir modeling) with practical data analytics in SQL, Python, Excel, and Tableau.
Portfolio Website: https://abdirahmansiyad.github.io/
Email: Abdirahman.Osman.Siyad@gmail.com

## 🛡️ License
Distributed under the MIT License. See LICENSE for more information.


