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

The analysis is built on the **Google Analytics 4 ecommerce BigQuery export sample dataset**, which simulates a production ecommerce analytics implementation.

### Dataset Characteristics

The dataset contains event-level GA4 logs including:

* **User interactions:** `page_view`, `view_item`, `add_to_cart`, `begin_checkout`, `purchase`
* **Session identifiers:** `ga_session_id`, `user_pseudo_id`
* **Transaction metadata:** `transaction_id`, revenue fields
* **Acquisition attributes:** traffic medium and source
* **Device information:** desktop, mobile, tablet classification
* **Time dimensions:** event timestamps and dates

The dataset covers a fixed historical period (late 2020 – early 2021) and enables full reconstruction of user purchase journeys.

### Modeling Approach

Raw events are transformed into analytical views:

1. **Session assembly** — reconstruct unique sessions from event streams
2. **Funnel flags** — assign binary indicators for funnel steps
3. **Daily aggregation** — compute conversion KPIs over time
4. **Segment analysis** — evaluate acquisition and device performance
5. **Time-to-purchase metrics** — measure behavioral latency

This layered modeling structure reflects analytics engineering best practices.

---

## Funnel Performance Analysis

### Executive Summary

Overall traffic volume is stable, but monetization performance is driven more by **mid-funnel efficiency and segment quality** than by raw session growth.

The largest performance differences emerge across acquisition segments and user types, where lower-volume returning-user segments demonstrate materially higher revenue efficiency than high-volume new-user traffic.

Funnel diagnostics show variability in checkout behavior and purchase timing, suggesting friction and inconsistency in user journeys. Improving mid-funnel progression and prioritizing high-efficiency segments represent the clearest opportunities for optimization.

---

## Funnel Structure & Conversion Performance

**Charts used:**

* Funnel Step Conversion Rates
* Traffic vs Conversion Rate

The funnel tracks:

**Session → Product View → Checkout → Purchase**

Findings:

* Session-to-purchase conversion is low relative to total traffic
* The largest drop-off occurs between product interaction and checkout initiation
* Checkout-to-purchase conversion is comparatively stronger and stable

Revenue fluctuations align more closely with conversion efficiency than with session volume, indicating that **mid-funnel optimization has higher leverage than traffic expansion**.

---

## Revenue Performance & Efficiency

**Charts used:**

* Revenue Over Time
* Orders vs AOV
* Revenue per Session

Revenue trends generally follow traffic but show spikes driven by high-value transactions. These outliers affect averages and should be interpreted cautiously.

Revenue per session fluctuates alongside conversion performance, reinforcing that monetization efficiency depends primarily on funnel effectiveness rather than raw traffic growth.

---

## Acquisition & Segment Performance

**Charts used:**

* Segment Performance Summary table
* Revenue by Device and Channel
* Traffic Medium / Session → Purchase Conversion matrix

The largest individual traffic segments are concentrated in **new-user organic traffic**, including:

* Organic · Desktop · New users — **57,975 sessions**
* Organic · Mobile · New users — **39,668 sessions**

These segments generate high volume but modest revenue efficiency.

In contrast, certain returning-user segments deliver significantly higher monetization efficiency. For example:

**Referral · Desktop · Returning users**

* 15,019 sessions
* ~0.03 session→purchase conversion
* $38,381 revenue
* **$2.56 revenue per session**

This represents more than **5× higher revenue per session** than large new-user organic segments.

Traffic quality varies substantially by segment, suggesting that prioritizing efficient channels may improve ROI more effectively than increasing session counts.

---

## Funnel Friction & Time to Purchase

**Charts used:**

* Time to Purchase (Median vs P90)
* P90 View → Checkout & Median Checkout → Purchase
* Checkout Without Cart vs Cart Event Coverage

A persistent gap between median and 90th percentile purchase times indicates that while many users convert quickly, a subset experiences extended journeys.

This long-tail behavior suggests friction or inconsistent checkout flows. Variability in expected funnel steps may reflect either non-linear user behavior or instrumentation inconsistencies.

Standardizing checkout paths and reducing early friction could shorten time-to-conversion and improve efficiency.

---

## Analytical Limitations

* Extreme transaction values introduce volatility in averages
* Small segments produce unstable conversion estimates
* Some anomalies may reflect tracking gaps rather than behavior

These limitations highlight the importance of data validation and cautious interpretation.

---

## Recommendations

1. Improve mid-funnel progression to increase checkout initiation
2. Prioritize investment in high-efficiency returning-user segments
3. Validate tracking and investigate extreme revenue outliers
4. Simplify and standardize checkout flows
5. Apply minimum sample thresholds when evaluating segments

These actions focus on improving efficiency without proportional increases in acquisition spend.

---

## Dashboard Preview

*(Insert dashboard screenshots here)*

---

## Project Structure

```
/sql        → BigQuery SQL modeling views
/dashboard  → Dashboard screenshots
README.md   → Project case study
```

---

## Conclusion

Revenue performance is constrained more by funnel efficiency and segment quality than by traffic shortages.

Mid-funnel friction and acquisition variability represent the primary optimization levers. Targeted improvements in checkout progression and segment prioritization can materially increase monetization without expanding traffic volume.

This project demonstrates how structured data modeling and dashboard analytics support actionable business insights.
