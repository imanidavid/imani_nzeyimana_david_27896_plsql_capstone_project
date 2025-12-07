# KPI Definitions

## 1. Gross Margin %
**Formula:**  
(margin_amount / net_sales) * 100  
**Source:** SALES_LINE  
**Purpose:** Measures profitability per product, branch, or time period.

## 2. Net Sales
**Formula:**  
qty * unit_price * (1 - discount_pct / 100)  
**Source:** SALES_LINE  
**Purpose:** Shows true revenue after discounts.

## 3. Margin Amount
**Formula:**  
net_sales - cost_at_sale  
(cost_at_sale retrieved from COST_HISTORY or PRODUCT snapshot)  
**Source:** SALES_LINE + COST_HISTORY  
**Purpose:** Tracks profitability in currency value.

## 4. Alert Count
**Formula:**  
COUNT(alert_id)  
**Source:** MARGIN_ALERT  
**Purpose:** Measures operational risk and number of low-margin events.

## 5. High-Discount Transactions
**Formula:**  
COUNT(SALES_LINE) WHERE discount_pct > threshold  
**Purpose:** Detects pricing policy abuse or aggressive discounting.

## 6. Cost Volatility Index
**Formula:**  
STDDEV(cost_price) over time  
**Source:** COST_HISTORY  
**Purpose:** Shows products affected by unstable supplier pricing.

## 7. Branch Profitability Score
**Formula:**  
Weighted metric combining:
- avg_margin %
- revenue share
- alert severity  
**Purpose:** Ranking branches based on operational performance.

## 8. Baseline Deviation
**Formula:**  
margin_pct - avg_margin (from MARGIN_BASELINE)  
**Purpose:** Helps detect anomalies beyond normal variance.
