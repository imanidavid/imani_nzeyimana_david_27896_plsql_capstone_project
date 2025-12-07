

# Profit Margin Monitoring System – PL/SQL Project

[![Oracle](https://img.shields.io/badge/Oracle-PL%2FSQL-red?style=flat\&logo=oracle)](https://www.oracle.com/)
[![Database](https://img.shields.io/badge/Database-Business%20Analytics-blue)]()
[![Status](https://img.shields.io/badge/Status-Complete-success)]()

> A complete enterprise-grade PL/SQL system designed to calculate, monitor, and audit product profit margins in real time. Includes automated alerts, audit logging, business intelligence components, and a fully normalized 3NF database schema.

##### **Developed by:** Imani Nzeyimana David
 **Student ID:** 27896
##### **Project Type:** PL/SQL Practicum Project
##### **Project Name:** Profit Margin Monitoring System

---

## Table of Contents

* [Overview](#overview)
* [Problem Statement](#problem-statement)
* [Project Objectives](#project-objectives)
* [Key Features](#key-features)
* [Project Structure](#project-structure)
* [Database Schema](#database-schema)
* [Core Components](#core-components)
* [Installation & Setup](#installation--setup)
* [Validation & Testing](#validation--testing)
* [Analytics & BI](#analytics--bi)
* [Documentation](#documentation)
* [Technologies](#technologies)
* [Author](#author)

---

## Overview

The **Profit Margin Monitoring System (PMMS)** is a PL/SQL-driven business monitoring platform that tracks product profitability at the transaction level. It detects low-margin sales, logs alerts, maintains historical cost records, and provides business intelligence insights for management decision-making.

This project demonstrates:

* **Advanced PL/SQL programming** (packages, triggers, jobs)
* **Data integrity and auditing**
* **Real-time decision support**
* **Enterprise database design (3NF)**
* **BI-ready fact/dimension modeling**

---

## Problem Statement

Businesses often operate with **unnoticed profit leaks** caused by extreme discounts, outdated cost prices, or manual pricing inconsistencies. Managers typically discover these issues too late, leading to revenue loss.
This system solves that by **automatically calculating margins**, **detecting low-margin transactions**, and **alerting managers in real time**.

---

## Project Objectives

* Calculate profit margins for every sales line.
* Detect and alert low-margin transactions.
* Maintain historical cost data.
* Provide audit trails for pricing, cost, and sales changes.
* Offer business intelligence insights and KPIs.
* Support scalable reporting through fact/dimension design.

---

## Key Features

### Margin & Alert Engine

* Real-time margin calculation.
* Automated low-margin alert insertion.
* Baseline comparison across periods.

### Audit Logging

* Tracks who changed what and when.
* Captures before/after values.
* Uses autonomous transactions for reliability.

### Business Intelligence

* KPI definitions (avg margin, alert rate, cost variance).
* Trend queries and dashboards.
* Fact/dimension-ready schema.

### Robust Database Design

* Fully normalized 3NF schema.
* Referential integrity through constraints.
* Sequences & indexes for performance.

---

## Project Structure

```
profit-margin-monitoring/
│
├── README.md
│
├── database/
│   ├── scripts/
│   │   ├── ddl_tables.sql
│   │   ├── sequences_indexes.sql
│   │   ├── ddl_baselines.sql
│   │   ├── user_setup.sql
│   │   ├── insert_test_data.sql
│   │   ├── plsql_packages.sql
│   │   ├── triggers.sql
│   │   ├── scheduler_jobs.sql
│   │   └── validation_queries.sql
│   └── documentation/
│       ├── ER_diagram.png
│       ├── data_dictionary.md
│       ├── assumptions.md
│       ├── architecture.md
│       └── design_decisions.md
│
├── queries/
│   ├── data_retrieval.sql
│   ├── analytics_queries.sql
│   └── audit_queries.sql
│
├── business_intelligence/
│   ├── bi_requirements.md
│   ├── dashboards.md
│   └── kpi_definitions.md
│
└── screenshots/
    ├── database_objects/
    ├── oem_monitoring/
    └── test_results/
```

---

## Database Schema

### Main Entities

| Table               | Purpose                          |
| ------------------- | -------------------------------- |
| **BRANCH**          | Business location information    |
| **PRODUCT**         | Item catalog + pricing           |
| **COST_HISTORY**    | Temporal cost tracking           |
| **SALES_ORDER**     | Customer orders                  |
| **SALES_LINE**      | Line-level order details         |
| **MARGIN_ALERT**    | Auto-generated alert records     |
| **MARGIN_BASELINE** | Periodic averages for comparison |
| **AUDIT_LOG**       | Full historical audit trail      |

### Normalization

* All tables built in **3NF**
* Historical tables separated (COST_HISTORY)
* Audit data kept externally (AUDIT_LOG)
* Clear PK–FK relationships

---

## Core Components

### **1. PL/SQL Package (margin_mon_pkg)**

Handles:

* Margin calculation
* Alert insertion
* Cost retrieval (historical-aware)
* Baseline evaluation

### **2. Triggers**

* Audit triggers (PRODUCT, COST_HISTORY, SALES_LINE)
* Margin alert triggers
* Prevents invalid pricing updates

### **3. DBMS Scheduler Jobs**

* Monthly baseline refresh
* Alert cleanup cycles

### **4. Test Data Generator**

* 40 products
* 120 orders
* 360 sales lines
* 80 baseline records
* Sample alert & audit entries

---

## Installation & Setup

### 1. Create PDB & Schema User

```sql
-- Adjust file paths per environment
CREATE PLUGGABLE DATABASE mon_27896_david_profitmargin_db
ADMIN USER david IDENTIFIED BY david
FILE_NAME_CONVERT = (
  'C:\APP\ORADATA\ORCL\PDBSEED\',
  'C:\APP\ORADATA\ORCL\MON_27896_DAVID_PROFITMARGIN_DB\'
);
```

Then:

```sql
ALTER PLUGGABLE DATABASE mon_27896_david_profitmargin_db OPEN;
```

Create user:

```sql
CREATE USER margin_user IDENTIFIED BY margin_user;
```

Grant privileges:

```sql
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW,
      CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER TO margin_user;
```

### 2. Run Scripts (in order)

```
1. ddl_tables.sql
2. sequences_indexes.sql
3. plsql_packages.sql
4. triggers.sql
5. scheduler_jobs.sql
6. insert_test_data.sql
7. validation_queries.sql
```

---

## Validation & Testing

Validation queries include:

* Table counts
* Data integrity checks
* Margin calculations
* Alert generation verification
* Audit log verification

Test results stored in:

```
/screenshots/test_results/
```

---

## Analytics & BI

### KPIs

* Average Product Margin %
* Low-Margin Transactions Count
* Cost Change Variance
* Margin Baseline Deviation (%)

### Dashboards

* Executive summary dashboard
* Alert monitoring dashboard
* Performance dashboard (sales vs margin trends)

### Analytical Queries

Available in:

```
queries/analytics_queries.sql
```

---

## Documentation

Full documentation available in:

```
documentation/
```

Includes:

* ERD
* Data dictionary
* Architecture
* Design decisions
* Assumptions

---

## Technologies

| Category        | Technology                              |
| --------------- | --------------------------------------- |
| **Database**    | Oracle Database 19c                     |
| **Language**    | SQL / PL/SQL                            |
| **Tools**       | SQL Developer                           |
| **Modeling**    | ERD, BPMN                               |
| **BI Approach** | KPIs, dashboards, fact/dimension design |

---

## 📬 Contact

**Imani Nzeyimana David**
###### Software Engineering Student | PL/SQL Developer
###### Kigali, Rwanda

[![GitHub](https://img.shields.io/badge/GitHub-imanidavid-181717?style=flat\&logo=github)](https://github.com/imanidavid)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat\&logo=linkedin)](https://www.linkedin.com/in/david-imani-ab9110369/)
[![Email](https://img.shields.io/badge/Email-imanidavid96%40gmail.com-D14836?style=flat\&logo=gmail)](mailto:imanidavid96@gmail.com)


---

#  License

This project is submitted as part of the academic requirements for the PL/SQL Practicum at **Adventist University of Central Africa (AUCA)**.
It is provided strictly for **educational and evaluation purposes**.

All rights reserved © 2025–2026 **Imani Nzeyimana David**.
Unauthorized commercial use, redistribution, or modification is not permitted without prior approval.

---

# Acknowledgments

Special appreciation to:

* **Mr. Eric Maniraguha**, course instructor.
* Oracle documentation and PL/SQL community resources that supported technical decisions.
* Fellow AUCA students for peer learning.




