# Data Dictionary – Profit Margin Monitoring System

This document describes the logical data model, entities, attributes, data types, constraints, and assumptions for the Profit Margin Monitoring System. The model is normalized to 3NF.

---

## 1. Entities and Attributes

### **BRANCH**
| Column       | Type              | Constraints                      |
|--------------|-------------------|----------------------------------|
| branch_id    | NUMBER            | PK                               |
| name         | VARCHAR2(100)     | NOT NULL, UNIQUE                 |
| location     | VARCHAR2(200)     |                                  |

**Notes:**  
- Each branch can have many sales orders.  



### **PRODUCT**
| Column       | Type              | Constraints                                   |
|--------------|-------------------|-----------------------------------------------|
| product_id   | NUMBER            | PK                                            |
| sku          | VARCHAR2(50)      | UNIQUE, NOT NULL                              |
| name         | VARCHAR2(200)     | NOT NULL                                      |
| category     | VARCHAR2(100)     |                                               |
| cost_price   | NUMBER(12,2)      | NOT NULL (latest cost snapshot)               |
| list_price   | NUMBER(12,2)      | NOT NULL                                      |
| active       | CHAR(1)           | DEFAULT 'Y', CHECK(active IN ('Y','N'))       |

**Assumptions:**  
- `cost_price` keeps the latest snapshot; history is tracked separately.



### **COST_HISTORY**
| Column        | Type              | Constraints                         |
|---------------|-------------------|-------------------------------------|
| cost_id       | NUMBER            | PK                                  |
| product_id    | NUMBER            | FK → PRODUCT(product_id), NOT NULL  |
| effective_date| DATE              | NOT NULL                            |
| cost_price    | NUMBER(12,2)      | NOT NULL                            |
| created_by    | VARCHAR2(50)      |                                     |
| created_on    | DATE              | DEFAULT SYSDATE                     |

**Notes:**  
- Immutable records; updates create new entries.  



### **SALES_ORDER**
| Column        | Type              | Constraints                         |
|---------------|-------------------|-------------------------------------|
| order_id      | NUMBER            | PK                                  |
| order_date    | DATE              | NOT NULL, DEFAULT SYSDATE           |
| branch_id     | NUMBER            | FK → BRANCH(branch_id)              |
| customer_id   | NUMBER            | Optional                            |
| total_amount  | NUMBER(14,2)      | NOT NULL                            |

**Assumptions:**  
- `total_amount` is stored for fast reporting though derivable.



### **SALES_LINE**
| Column       | Type              | Constraints                                      |
|--------------|-------------------|--------------------------------------------------|
| line_id      | NUMBER            | PK                                               |
| order_id     | NUMBER            | FK → SALES_ORDER(order_id)                       |
| product_id   | NUMBER            | FK → PRODUCT(product_id)                         |
| qty          | NUMBER(10,2)      | NOT NULL, CHECK(qty > 0), DEFAULT 1              |
| unit_price   | NUMBER(12,2)      | NOT NULL                                         |
| discount_pct | NUMBER(5,2)       | DEFAULT 0, CHECK(discount_pct BETWEEN 0 AND 100) |
| line_total   | NUMBER(14,2)      | NOT NULL                                         |
| created_on   | DATE              | DEFAULT SYSDATE                                  |

**Logic:**  
- `line_total` derived: `qty * unit_price * (1 - discount_pct/100)`.



### **MARGIN_ALERT**
| Column       | Type              | Constraints                                                   |
|--------------|-------------------|---------------------------------------------------------------|
| alert_id     | NUMBER            | PK                                                            |
| created_on   | DATE              | DEFAULT SYSDATE, NOT NULL                                     |
| order_id     | NUMBER            | Nullable FK → SALES_ORDER(order_id)                           |
| line_id      | NUMBER            | Nullable FK → SALES_LINE(line_id)                             |
| product_id   | NUMBER            | FK → PRODUCT(product_id)                                      |
| branch_id    | NUMBER            | FK → BRANCH(branch_id)                                        |
| margin_pct   | NUMBER(6,2)       | NOT NULL                                                      |
| reason       | VARCHAR2(400)     | NOT NULL                                                      |
| status       | VARCHAR2(20)      | DEFAULT 'OPEN', CHECK(status IN ('OPEN','REVIEWED','CLOSED')) |
| created_by   | VARCHAR2(50)      |                                                               |

**Notes:**  
- Alert can be tied to a sales line, an order, or both.



### **MARGIN_BASELINE**
| Column        | Type              | Constraints                                      |
|---------------|-------------------|--------------------------------------------------|
| baseline_id   | NUMBER            | PK                                               |
| product_id    | NUMBER            | FK → PRODUCT(product_id)                         |
| branch_id     | NUMBER            | Nullable FK → BRANCH(branch_id)                  |
| period_start  | DATE              | NOT NULL                                         |
| avg_margin    | NUMBER(6,2)       | NOT NULL                                         |
| stddev_margin | NUMBER(6,2)       | NOT NULL                                         |

**Recommendation:**  
- Add UNIQUE(product_id, branch_id, period_start)



### **AUDIT_LOG**
| Column       | Type              | Constraints               |
|--------------|-------------------|---------------------------|
| audit_id     | NUMBER            | PK                        |
| object_type  | VARCHAR2(50)      | NOT NULL                  |
| object_id    | NUMBER            | NOT NULL                  |
| changed_on   | DATE              | DEFAULT SYSDATE NOT NULL  |
| changed_by   | VARCHAR2(50)      |                           |
| change_type  | VARCHAR2(50)      |                           |
| old_value    | VARCHAR2(4000)    |                           |
| new_value    | VARCHAR2(4000)    |                           |



## 2. Normalization Justification

### **1NF**
- No repeating groups.  
- Every column holds atomic data.  
- SALES_LINE separates product rows rather than embedding lists.

### **2NF**
- No partial dependencies.  
- Surrogate keys (line_id, order_id, cost_id) avoid composite partial key issues.

### **3NF**
- No transitive dependencies.  
- Product cost history is separated into COST_HISTORY.  
- Baselines stored in MARGIN_BASELINE to avoid derived attribute duplication.



## 3. BI Considerations

### **Fact Tables**
- **SALES_FACT** (from SALES_LINE): sales metrics, margins, quantities.  
- **ALERT_FACT**: alert metrics for trend analysis.

### **Dimension Tables**
- PRODUCT_DIM  
- BRANCH_DIM  
- TIME_DIM  
- CUSTOMER_DIM (optional)  
- USER_DIM (based on created_by fields)

### **Slowly Changing Dimensions**
- PRODUCT_DIM → Type 2 (track list_price, category changes)  
- BRANCH_DIM → Type 1 (overwrite changes)  

### **Aggregation Levels**
- Product × Branch × Day  
- Product × Month  
- Category × Month  

### **Audit Trail Design**
- AUDIT_LOG captures master and transaction changes.  
- Triggers ensure data lineage for BI.



## 4. Assumptions

1. Single currency business unless multi-currency is added.  
2. PRODUCT.cost_price stores the latest snapshot.  
3. Historical cost accuracy can use COST_HISTORY based on effective dates.  
4. Margin calculations can refer to cost at time of sale if required.  
5. Indexing should focus on SALES_LINE, COST_HISTORY, and MARGIN_ALERT for performance.



# End of Data Dictionary
