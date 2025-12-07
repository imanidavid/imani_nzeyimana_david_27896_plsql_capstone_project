# **System Architecture – Profit Margin Monitoring System**

## **1. Overview**

This document describes the architectural structure of the Profit Margin Monitoring System.
The system is designed as a database-centric application fully implemented in Oracle PL/SQL, using a modular structure that separates **data storage**, **business logic**, **auditing**, and **analytics**.

---

## **2. Architecture Layers**

### **A. Data Storage Layer (Core Tables)**

This layer contains the normalized 3NF dataset that supports all operations.

**Master Data**

* `BRANCH` – business locations
* `PRODUCT` – product catalog
* `COST_HISTORY` – historical cost values

**Transactional Data**

* `SALES_ORDER` – sales headers
* `SALES_LINE` – detailed sales items

**Analytical Structures**

* `MARGIN_BASELINE` – historical monthly averages
* `MARGIN_ALERT` – anomaly detection log

**Audit Layer**

* `AUDIT_LOG` – system-wide audit trail

---

## **3. PL/SQL Logic Layer**

### **A. Margin Engine Package (`margin_mon_pkg`)**

Handles:

* Line margin calculation
* Order-level margin evaluation
* Automated alert creation
* Baseline refresh jobs
* Utility functions for reporting

### **B. Audit Package (`audit_pkg`)**

A generic auditing utility that records:

* Who changed data
* What changed
* Before/after values
* Time of action and object type

### **C. Triggers**

1. **Operational triggers**

   * `trg_sales_line_after_ins` – margin evaluation
2. **Audit triggers**

   * On PRODUCT updates
   * On COST_HISTORY inserts
   * On SALES_LINE updates

### **D. Scheduler Jobs**

* Baseline refresh job
* Optional night audit job for large data volumes

---

## **4. Security Layer**

* Dedicated schema user: `MARGIN_USER`
* Least-privilege grants for tables, triggers, and packages
* SYS and SYSTEM only used for PDB creation

---

## **5. Data Flow Summary**

1. **Sales clerk enters an order** → data stored in `SALES_ORDER` and `SALES_LINE`
2. **Trigger fires** → calls `margin_mon_pkg.evaluate_order_margin`
3. **System logs margin %**
4. **If low margin** → entry added to `MARGIN_ALERT`
5. **Managers review alerts** for pricing/cost actions
6. **Nightly job refreshes baselines** → stored in `MARGIN_BASELINE`
7. **Audit triggers capture all changes** → written to `AUDIT_LOG`

---

## **6. BI Integration**

Data is ready for BI tools:

* Fact table: SALES_LINE (derived)
* Dimensions: PRODUCT, BRANCH, TIME
* Alerts become decision-support events
* Baselines support trend analytics and forecasting

---

## **7. Architecture Diagram (text-based)**

```
                 +-----------------------+
                 |     Front-end App     |
                 +-----------+-----------+
                             |
                      Sales Input
                             |
                        (Oracle DB)
                             |
+---------------------------+----------------------------+
|                   DATA LAYER (3NF)                     |
| BRANCH | PRODUCT | SALES_ORDER | SALES_LINE | BASELINE |
+---------------------------+----------------------------+
                             |
                      Margin Engine (PL/SQL)
                             |
                 +-----------+-----------+
                 |     MARGIN_ALERT      |
                 +-----------+-----------+
                             |
                    BI / Analytics Layer
                             |
                   Dashboards and KPIs
```