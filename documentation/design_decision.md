# **Design Decisions – Profit Margin Monitoring System**

## **1. Normalization Approach**

All tables follow **3NF** to avoid redundancy:

* **PRODUCT** stores only the latest cost snapshot; historical values move to **COST_HISTORY**
* **SALES_LINE** stores transactional details; totals computed explicitly
* **MARGIN_BASELINE** stores aggregated monthly values for efficient BI usage

Reason: Maintain clean master data, reduce update anomalies, and support analytical models.

---

## **2. Surrogate Keys**

Every table uses `NUMBER` surrogate keys via Oracle sequences:

* Better performance than natural keys
* Stable join keys for BI systems
* Avoids cascading key updates

---

## **3. Cost Strategy**

Cost stored in two places intentionally:

* `PRODUCT.cost_price` = fast-access snapshot
* `COST_HISTORY` = historical timeline for BI comparisons

Reason: Balance performance and accuracy.

---

## **4. Margin Calculation**

Margins are computed using:

```
margin_pct = (net_price – cost_price) / net_price * 100
```

**net_price** includes discount logic:
`unit_price * (1 – discount/100)`

Reason: Simple formula, universal across businesses, handles varied pricing models.

---

## **5. Alerting Strategy**

Alerts stored separately (`MARGIN_ALERT`) because:

* Alerts are analytical events, not transactional data
* One sales line may produce zero, one, or multiple alerts
* Alerts need long-term retention for BI purposes

---

## **6. Triggers vs. Scheduled Jobs**

**Triggers** → immediate margin validation
**Scheduled Job** → monthly baseline refresh

Reason: Real-time accuracy + periodic optimisation.

---

## **7. Auditing Strategy**

A generic audit package `audit_pkg` logs all critical object changes:

* PRODUCT updates
* COST_HISTORY inserts
* SALES_LINE updates

Choice rationale:

* Centralized logic
* Easier to expand
* SQL Developer-friendly for debugging

---

## **8. Security Decisions**

* A dedicated PDB created for isolation
* A separate schema (`MARGIN_USER`) for all objects
* SYS/SYSTEM only used for DBA-level tasks

Reason: Best practice for Oracle environments.

---

## **9. BI Considerations**

The design supports dimensional modeling:

* **Fact:** SALES_LINE
* **Dimensions:** PRODUCT, BRANCH, TIME
* **Event table:** MARGIN_ALERT

Reason: Enables KPIs like margin %, anomaly rate, branch comparison.

---

## **10. Performance Considerations**

* Strategic indexing on FK columns
* Avoided redundant indexes
* Use of `bulk collect` in future enhancements
* Line totals pre-calculated to reduce workload on BI tools

---

## **11. Error Handling**

All packages include exception blocks for:

* Division-by-zero margin errors
* Null cost scenarios
* Incorrect discount values

Reason: Keep data consistent and prevent alert spam.

---

## **12. Assumptions**

(Summary from assumptions.md)

* Single-currency model
* Cost changes tracked monthly
* Discounts are always percentage-based
* Branch IDs remain static
* BI tools able to consume Oracle views/tables