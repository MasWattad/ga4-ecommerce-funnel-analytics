# 📊 GA4 Ecommerce Funnel Analytics — BigQuery + Looker Studio

## Overview

This case study evaluates end-to-end ecommerce funnel performance using event-level behavioral data modeled in Google BigQuery and visualized through interactive Looker Studio dashboards.

The analysis examines how users progress through the purchase funnel, how revenue is distributed across acquisition segments, and where inefficiencies or friction arise in the conversion journey. By combining funnel conversion metrics, revenue indicators, and segment-level performance analysis, the study provides a structured view of the factors influencing monetization outcomes.

This framework supports systematic assessment of user behavior and highlights opportunities to improve conversion efficiency and overall funnel performance.

---

## Live Dashboard

👉 **Interactive dashboard:**   https://lookerstudio.google.com/s/tyfZr_mxm-I

![Executive Dashboard](pictures/d1.png)

![Executive Dashboard](pictures/d2.png)

![Executive Dashboard](pictures/dd3.png)

---

## Technologies and Analytical Stack

This project was implemented using a cloud analytics stack designed for event-level behavioral analysis and performance reporting:

* **Google BigQuery** — Analytical data warehouse used to query and aggregate GA4 event data, supporting scalable SQL transformations and computation of session-level funnel metrics and revenue KPIs.

* **SQL Modeling** — Structured SQL views organize event streams into reusable analytical layers, enabling consistent calculation of funnel conversion rates, segment performance metrics, and time-to-purchase statistics.

* **Google Analytics 4 (GA4) BigQuery Export Dataset** — Source ecommerce event dataset containing user interactions, session identifiers, acquisition attributes, and transaction metadata required to reconstruct purchase journeys.

* **Looker Studio** — Dashboarding platform used to build interactive visualizations for monitoring funnel performance, revenue trends, and acquisition quality.

---

## Dataset Description

This analysis is based on the public **Google Analytics 4 (GA4) ecommerce sample dataset** available in BigQuery (`bigquery-public-data.ga4_obfuscated_sample_ecommerce`). The dataset contains anonymized event-level logs that simulate a production ecommerce analytics environment.

The project uses GA4 event records such as **page views, product interactions, checkout actions, and purchases**, along with session identifiers, acquisition attributes, device categories, and transaction metadata. These fields enable reconstruction of session-level purchase journeys and measurement of funnel performance.

The dataset spans a fixed historical period (late 2020 to early 2021) and supports time-series analysis of conversion behavior and revenue trends.

---

## Modeling Approach

Event-level GA4 data is transformed into structured analytical views that support funnel and revenue analysis:

* **Session reconstruction** — events are grouped into unique sessions using GA4 session identifiers
* **Funnel flags** — session-level indicators capture progression through key funnel steps
* **Daily aggregation** — conversion metrics and revenue KPIs are summarized over time
* **Segment analysis** — performance is evaluated by acquisition channel and device
* **Time-to-purchase metrics** — latency between funnel milestones is measured

This layered SQL modeling approach converts raw event streams into stable business metrics suitable for executive reporting and behavioral diagnostics.

---
## Funnel Performance Analysis

### Executive Summary

Overall traffic volume remains relatively stable across the reporting period, but monetization performance is driven primarily by **mid-funnel efficiency and acquisition segment quality**, rather than by raw session growth.

The largest performance differences appear across acquisition segments and user types. Several lower-volume returning-user segments demonstrate materially higher revenue efficiency than high-volume new-user traffic. Funnel diagnostics also show variability in checkout behavior and purchase timing, indicating friction and inconsistency in parts of the user journey.

Together, the dashboards indicate that improving mid-funnel progression and prioritizing high-efficiency segments represent the clearest opportunities to increase revenue efficiency without proportional traffic expansion.

---

### Funnel Structure & Conversion Performance

**Charts referenced:** Funnel Step Conversion Rates; Traffic vs Conversion Rate

The funnel follows the progression:

**Session → Product View → Checkout → Purchase**

Key observations:

* Session-to-purchase conversion is low relative to total traffic
* The largest and most consistent drop-off occurs between product interaction and checkout initiation
* Checkout-to-purchase conversion is comparatively stronger and more stable

Revenue variability aligns more closely with changes in conversion efficiency than with fluctuations in session volume. This indicates that **mid-funnel optimization has greater impact on revenue than increasing top-of-funnel traffic alone**.

---

### Revenue Performance & Efficiency

**Charts referenced:** Revenue Over Time; Orders vs AOV; Revenue per Session

Revenue trends broadly track traffic patterns but include periodic spikes associated with high-value transactions. These outliers influence averages and should be interpreted cautiously.

Revenue per session moves in parallel with conversion performance, reinforcing that monetization efficiency is primarily driven by funnel effectiveness rather than raw traffic growth. Periods of higher revenue per session correspond to improved session-to-purchase conversion.

---

### Acquisition & Segment Performance

**Charts referenced:** Segment Performance Summary Table; Revenue by Device and Channel; Traffic Medium / Session → Purchase Conversion Matrix

Performance is reported at the **segment-row level** (Traffic Medium × Device Category × New vs Returning). The largest rows by volume are **new-user organic traffic**, including:

* **Organic · Desktop · New users — 57,975 sessions**
* **Organic · Mobile · New users — 39,668 sessions**

These segments contribute the most sessions but relatively low revenue efficiency.

By contrast, **Referral · Desktop · Returning users** delivers **15,019 sessions**, ~**0.03** session-to-purchase conversion, **$38,381 revenue**, and **$2.56 revenue per session** — over **5× higher revenue per session** than the large new-user organic rows.

The dashboards show clear variation in monetization by channel, device, and user type, indicating that prioritizing high-efficiency segments is likely more impactful than increasing total traffic volume.

---

### Funnel Friction & Time to Purchase

**Charts referenced:** Time to Purchase (Median vs P90); P90 View → Checkout & Median Checkout → Purchase; Checkout Without Cart vs Cart Event Coverage

A persistent gap between median and 90th percentile purchase times indicates that while many users complete purchases quickly, a subset experiences extended conversion journeys.

This long-tail behavior suggests friction or inconsistency in checkout flows. Variability in expected funnel steps may reflect non-linear user behavior or instrumentation inconsistencies. Standardizing checkout paths and reducing early friction could shorten time-to-conversion and improve overall efficiency.

---

### Analytical Limitations

* Extreme transaction values introduce volatility in revenue averages
* Small segments produce unstable conversion estimates
* Some anomalies may reflect tracking gaps rather than true behavior

These factors highlight the importance of ongoing data validation and cautious interpretation.

---

### Recommendations

* Improve mid-funnel progression to increase checkout initiation
* Prioritize investment in high-efficiency returning-user segments
* Validate tracking and investigate extreme revenue outliers
* Simplify and standardize checkout flows
* Apply minimum sample thresholds when evaluating segment performance

These actions focus on improving efficiency without proportional increases in acquisition spend.

---

### Conclusion

Revenue performance is constrained more by **funnel efficiency and segment quality** than by traffic shortages. Mid-funnel friction and acquisition variability represent the primary optimization levers.

Targeted improvements in checkout progression and segment prioritization can materially increase monetization without expanding traffic volume. This analysis demonstrates how structured data modeling and dashboard analytics support clear, actionable business insights.



