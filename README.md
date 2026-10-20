# Cookie Cats A/B Testing and Experimentation Analysis

## Project Overview

This project analyses an A/B test from the mobile game **Cookie Cats** to evaluate whether moving the first progression gate from **level 30** to **level 40** improves player retention and engagement.

The project was built as an end-to-end product analytics case study using:

* PostgreSQL for data storage, validation, and SQL analysis
* Python for statistical testing, bootstrapping, and visualisation
* Power BI for dashboard development
* Git and GitHub for version control and portfolio presentation

## Business Problem

Cookie Cats uses progression gates where players must wait or make an in-app purchase before continuing. The product team tested whether moving the first gate from level 30 to level 40 would improve player experience and increase retention.

The main business question was:

**Should the company move the first progression gate from level 30 to level 40?**

## Dataset

The dataset contains 90,189 players assigned to one of two experiment groups:

| Group   | Description                               |
| ------- | ----------------------------------------- |
| gate_30 | Control group with the gate at level 30   |
| gate_40 | Treatment group with the gate at level 40 |

Main columns:

| Column         | Description                              |
| -------------- | ---------------------------------------- |
| userid         | Unique player ID                         |
| version        | Experiment group                         |
| sum_gamerounds | Total game rounds played                 |
| retention_1    | Whether the player returned after 1 day  |
| retention_7    | Whether the player returned after 7 days |

The raw dataset is not included in this repository. It should be downloaded separately and placed in `data/raw/`.

## Tools Used

* PostgreSQL
* Python
* Pandas
* NumPy
* SciPy
* Statsmodels
* SQLAlchemy
* Matplotlib
* Power BI
* Git and GitHub

## Project Structure

```text
cookie-cats-ab-testing/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── images/
│
├── notebooks/
│   └── 01_ab_testing_analysis.ipynb
│
├── powerbi/
│   └── Cookie_Cats_AB_Testing_Dashboard.pbix
│
├── reports/
│   └── initial_sql_findings.md
│
├── sql/
│   ├── 01_create_raw_table.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_create_analysis_view.sql
│   ├── 04_experiment_kpis.sql
│   ├── 05_treatment_effects.sql
│   └── 06_powerbi_views.sql
│
├── requirements.txt
├── .gitignore
└── README.md
```

## Methodology

The analysis followed a structured experimentation workflow:

1. Defined the business problem and experiment hypothesis
2. Imported the raw dataset into PostgreSQL
3. Created raw and analytics database schemas
4. Performed data-quality checks
5. Built SQL views for analysis and Power BI reporting
6. Analysed retention and engagement metrics
7. Tested experiment validity using a Sample Ratio Mismatch check
8. Conducted statistical hypothesis tests in Python
9. Used bootstrap simulation to estimate uncertainty
10. Calculated Minimum Detectable Effect
11. Built a Power BI dashboard
12. Produced a business recommendation

## Data Quality Checks

The dataset passed key quality checks:

| Check                       | Result |
| --------------------------- | -----: |
| Total players               | 90,189 |
| Unique users                | 90,189 |
| Duplicate users             |      0 |
| Missing values              |      0 |
| Negative game-round records |      0 |
| Zero-round players          |  3,994 |
| Extreme engagement outliers |      1 |

One isolated player had 49,854 game rounds, far above the second-highest value. This record was retained in the raw data but excluded from the main engagement average through an analysis column.

## Key Results

### Sample Allocation

| Group   | Players |
| ------- | ------: |
| gate_30 |  44,700 |
| gate_40 |  45,489 |

A Sample Ratio Mismatch test produced a p-value of **0.0086**, indicating an allocation warning under an assumed 50/50 split.

### Retention Results

| Metric          | Control | Treatment |   Effect |
| --------------- | ------: | --------: | -------: |
| Day 1 retention |  44.82% |    44.23% | -0.59 pp |
| Day 7 retention |  19.02% |    18.20% | -0.82 pp |

### Statistical Testing

| Metric          |   Effect | p-value | Decision                          |
| --------------- | -------: | ------: | --------------------------------- |
| Day 1 retention | -0.59 pp |  0.0744 | Not statistically significant     |
| Day 7 retention | -0.82 pp |  0.0016 | Statistically significant decline |

Day 7 retention was selected as the primary metric because it better reflects sustained player engagement.

### Bootstrap Results

| Metric          | 95% Bootstrap Interval | Share of Effects Above Zero |
| --------------- | ---------------------: | --------------------------: |
| Day 1 retention |       [-1.25, 0.06] pp |                       3.47% |
| Day 7 retention |      [-1.34, -0.31] pp |                       0.08% |

The Day 7 bootstrap interval remained entirely below zero, supporting the conclusion that the treatment reduced retention.

### Engagement Results

| Metric         | Control | Treatment | Difference |
| -------------- | ------: | --------: | ---------: |
| Average rounds |   51.34 |     51.30 |      -0.04 |
| Median rounds  |      17 |        16 |         -1 |

The Mann-Whitney U test returned a p-value of **0.050892**, and the rank-biserial effect size was **-0.007504**, indicating a negligible practical engagement effect.

## Power BI Dashboard

The Power BI dashboard includes five pages:

1. Executive Summary
2. Experiment Health
3. Retention Analysis
4. Engagement Analysis
5. Statistical Results and Final Recommendation

### Executive Summary

![Executive Summary](images/executive_summary.png)

### Experiment Health

![Experiment Health](images/experiment_health.png)

### Retention Analysis

![Retention Analysis](images/retention_analysis.png)

### Engagement Analysis

![Engagement Analysis](images/engagement_analysis.png)

### Statistical Results

![Statistical Results](images/statistical_results.png)

## Final Recommendation

The analysis does **not** support rolling out `gate_40`.

The treatment group showed:

* Lower Day 1 retention
* Statistically significant lower Day 7 retention
* No meaningful improvement in game-round engagement
* A negative primary-metric result supported by bootstrap analysis

The recommended decision is to **keep the gate at level 30**.

However, because the experiment triggered a Sample Ratio Mismatch warning, the assignment and logging process should be reviewed. If the imbalance cannot be explained, the experiment should be rerun before making a final production decision.

## Business Impact

For every 1,000 users exposed to `gate_40`, approximately 8 fewer users returned after seven days compared with `gate_30`.

At larger product scale, this could meaningfully reduce retained users without providing a compensating engagement benefit.

## How to Run This Project

1. Clone the repository.
2. Download the Cookie Cats dataset separately.
3. Place the CSV file in:

```text
data/raw/cookie_cats.csv
```

4. Create the PostgreSQL database:

```sql
CREATE DATABASE cookie_cats_ab;
```

5. Run the SQL scripts in order from the `sql/` folder.
6. Create a Python virtual environment.
7. Install dependencies:

```bash
pip install -r requirements.txt
```

8. Create a `.env` file using this format:

```text
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cookie_cats_ab
```

9. Run the notebook:

```text
notebooks/01_ab_testing_analysis.ipynb
```

10. Open the Power BI dashboard from the `powerbi/` folder.

## Skills Demonstrated

* A/B testing
* Product analytics
* Growth analytics
* Retention analysis
* SQL data modelling
* Data validation
* Statistical hypothesis testing
* Confidence intervals
* Bootstrap simulation
* Minimum Detectable Effect analysis
* Power BI dashboarding
* Business recommendation writing
* GitHub project documentation
