# Dashboards Specification

## 1. Margin Performance Dashboard
### Purpose
Show overall profitability and highlight declining trends.

### Key Visuals
- Line chart: Margin % over time (daily/weekly/monthly)
- Heatmap: Margin by branch vs product category
- KPI tiles:
  - Average margin %
  - Total revenue
  - Number of low-margin alerts this period
  - Highest-risk branch

### Filters
- Branch
- Product category
- Date range

---

## 2. Discount & Cost Impact Dashboard
### Purpose
Analyze how discounts and cost changes affect profitability.

### Visuals
- Scatter plot: discount % vs margin %
- Step chart: cost changes from COST_HISTORY
- Bar chart: top 10 products with discount-driven margin loss

### Filters
- Product
- Date range
- Branch

---

## 3. Alerts Monitoring Dashboard
### Purpose
Track operational risks and alert history.

### Visuals
- Timeline of alerts generated
- Pie chart: alert status (open, reviewed, closed)
- Table: top recurring low-margin products
- Bubble chart: alerts by product vs margin severity

---

## 4. Branch Performance Dashboard
### Purpose
Compare profitability and performance across branches.

### Visuals
- Ranking: branch margin %
- Map (optional): branch distribution
- Bar chart: revenue vs margin per branch

### Filters
- Time period
- Product category
