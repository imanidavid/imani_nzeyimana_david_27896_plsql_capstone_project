# Business Intelligence Requirements

## 1. Strategic BI Goals
- Identify products, branches, and periods with declining profit margins.
- Detect unusual discount patterns and high-risk transactions.
- Provide managers with early warning signals through automated alerts.
- Track cost changes and their impact on margins over time.

## 2. Required BI Capabilities
- Margin trend analysis (daily, weekly, monthly).
- Cost variance tracking based on COST_HISTORY.
- Discount impact analysis per product and per branch.
- Alert pattern analysis from MARGIN_ALERT.
- Sales volume and revenue breakdowns.

## 3. Data Sources
- SALES_LINE (fact-level sales detail)
- SALES_ORDER (transaction headers)
- PRODUCT, BRANCH (dimensions)
- COST_HISTORY (temporal dimension)
- MARGIN_ALERT (exception fact table)
- MARGIN_BASELINE (baseline metrics)

## 4. BI Metrics Needed
- Gross margin %
- Margin amount
- Discount %
- Cost movement per product
- Number of alerts generated per period
- Branch performance ranking

## 5. Reporting Requirements
- Monthly executive margin summary
- Branch comparison dashboard
- Product category performance view
- High-discount transaction report
- Low-margin alert heatmap

## 6. Users
- Finance managers  
- Branch managers  
- Pricing analysts  
- Executives

