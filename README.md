<div align="center">

# 🛢️ Petroleum Surveillance & Completion Analytics Portfolio
### Production Surveillance, Automated Shut-In Detection & Unconventional Completion Engine (MySQL 8.0+)

[![Database](https://img.shields.io/badge/Database-MySQL_8.0%2B-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](#)
[![Domain](https://img.shields.io/badge/Domain-Petroleum_Data_Engineering-0F766E?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

</div>

## 👋 Welcome!

Welcome to my **Petroleum Surveillance & Completion Analytics Portfolio**! 🚀

Whether you are an engineering manager, data lead, recruiter, or fellow practitioner, I am glad you are here. This repository showcases practical **MySQL 8.0+** workflows built for upstream petroleum surveillance and reservoir completion analytics covering structured table ingestion, `NULL` normalization, composite primary keys, window function event isolation for Pressure Transient Analysis (PTA) screening, and lateral normalized completion feature engineering.

Feel free to explore the SQL scripts, clone the repository, and review the workflows. If you have any questions, feedback, or collaboration opportunities, reach out anytime!

---

## 📖 Executive Summary

This repository presents two focused **MySQL 8.0+** SQL projects designed for upstream oil and gas surveillance and completion analytics:
1. **Volve Production Surveillance & Automated Shut In Detection** (`01_volve_production_shut_in_surveillance`): Isolates multi-day well shut-in and pressure build-up windows from daily North Sea Volve production records for PTA screening.
2. **Unconventional EUR & Completion Optimization Engine** (`02_unconventional_eur_completion_engine/`): Normalizes proppant and fluid stimulation intensities per `1,000 ft` of horizontal lateral and prepares clean analytical/ML training rows for 12-month cumulative oil.

> **Note on MySQL 8.0+ & macOS Workflow:**  
> All scripts are written and tested for **MySQL 8.0+** in **MySQL Workbench** on macOS, including global `local_infile` configuration (`SET GLOBAL local_infile = 1;` and client `OPT_LOCAL_INFILE=1`), `NULLIF(TRIM(...), '')` empty-value handling, and consolidated execution logging via `tmp_log`[cite: 1, 2, 4].

> ** 📊 Data Source & Attribution:**
The data used in this project was sourced from Kaggle at https://www.kaggle.com/code/lordkun/volve-production-with-ml/input. It was selected because it offers rich operational data and is openly available for general use. Special thanks to the dataset author and the Kaggle community for making this dataset accessible for engineering analysis and experimentation. 
---

## 🏗️ Workflow Architecture

The repository organizes each project into clean ingestion/DDL and analytical query workflows so table setup and domain analytics stay modular and easy to audit:

```text
+-----------------------+      +-----------------------+      +-----------------------+
|   Source Datasets     |      |  DDL & Bulk Ingestion |      |  Analytical & Feature |
|  (Daily Volve &       | ---> |  (MySQL 8.0+ Tables,  | ---> |  SQL Workflows        |
|   Unconventional CSVs)|      |   PKs & NULL Cleanup) |      |  (CTEs, Windows, EUR) |
+-----------------------+      +-----------------------+      +-----------------------+
                                                                           |
                                                                           v
                                                              +-----------------------+
                                                              | PTA Screening &       |
                                                              | Completion Analytics  |
                                                              +-----------------------+

## 🛠️ Tech Stack & Prerequisites
Database Engine: MySQL 8.0+

Database Client: MySQL Workbench (macOS)[cite: 2, 4]

Querying & Analytics: SQL (CTEs, Window Functions LAG() SUM() OVER(), NULLIF, Aggregations)

Version Control: Git & GitHub

## 📂 Repository Structure
petroleum surveillance completion sql/
├── README.md
├── LICENSE
├── .gitignore
├── Project 1 (volve_production_shut_in_surveillance)
│   ├── ddl_and_ingestion/
│   │   └── 01_create_and_load_volve_daily.sql
│   └── analytics/
│       └── 02_isolate_shut_in_buildup_events.sql
└── Project 2 (unconventional_eur_completion_engine)
    ├── ddl_and_ingestion/
    │   └── 01_create_unconventional_completions.sql
    └── analytics/
        └── 02_normalize_completion_intensity.sql

## 🌟 About the Author
Hi! I am Abdirahman Osman Siyad, a Petroleum Engineer & Data Analyst based in New Cairo, Cairo, Egypt, holding a B.E. in Petroleum Engineering from NED University of Engineering & Technology and PEC registration (PETGAS/004551).
I combine upstream petroleum engineering experience (including SSGC gas transmission and hydraulic fracturing/reservoir modeling) with practical data analytics in SQL, Python, Excel, and Tableau.
Portfolio Website: https://abdirahmansiyad.github.io/
Email: Abdirahman.Osman.Siyad@gmail.com

## 🛡️ License
Distributed under the MIT License. See LICENSE for more information.


