# Cookie Cats | A/B Testing & Product Analytics

**An end-to-end experimentation project using PostgreSQL, Python, statistical inference, and Power BI to evaluate the impact of a mobile game's progression-gate change on player retention.**

[![Python](https://img.shields.io/badge/Python-3.13-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Analytics-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)](https://jupyter.org/)

---

## Executive Summary

**Should Cookie Cats move its first progression gate from level 30 to level 40?**

This project analyses an A/B experiment involving **90,189 players** to evaluate the effect of moving the first progression gate on player retention and engagement.

The analysis combines SQL-based data validation, Python statistical testing, bootstrap confidence intervals, and an interactive Power BI dashboard to translate experiment data into a product decision.

| Key metric | Gate at level 30 | Gate at level 40 | Observed difference |
|---|---:|---:|---:|
| Day 1 retention | 44.82% | 44.23% | -0.59 percentage points |
| Day 7 retention | 19.02% | 18.20% | -0.82 percentage points |
| Average game rounds* | 51.34 | 51.30 | -0.04 |
| Median game rounds | 17 | 16 | -1 |

<sub>*Average game rounds are reported using the project's outlier-exclusion rule.</sub>

### Recommendation

**Do not roll out the level-40 gate based on the current evidence.**

Day 7 retention was lower in the treatment group, and the difference was statistically significant. Engagement showed no meaningful practical improvement. However, the experiment also triggered a sample-ratio mismatch (SRM) warning, so assignment and event-logging processes should be investigated before treating the result as definitive.

---

## Dashboard Preview

The Power BI report contains five pages covering the experiment's business outcome, allocation health, retention, engagement, and statistical evidence.

### Executive Summary
![Executive Summary Dashboard](images/executive_summary.png)

### Experiment Health
![Experiment Health Dashboard](images/experiment_health.png)

### Retention Analysis
![Retention Analysis Dashboard](images/retention_analysis.png)

### Engagement Analysis
![Engagement Analysis Dashboard](images/engagement_analysis.png)

### Statistical Results
![Statistical Results Dashboard](images/statistical_results.png)

**Interactive report:** [`powerbi/Cookie_Cats_AB_Testing_Dashboard.pbix`](powerbi/Cookie_Cats_AB_Testing_Dashboard.pbix)

Download the PBIX file and open it in Power BI Desktop. Depending on your environment, you may need to update the PostgreSQL connection and refresh the data.

---

## Business Context

Cookie Cats is a mobile game in which progression gates interrupt gameplay until players wait or make an in-app purchase.

The experiment compared two versions:

- **Control — `gate_30`:** the first progression gate appears at level 30.
- **Treatment — `gate_40`:** the first progression gate appears at level 40.

The objective is to determine whether delaying the gate improves the player experience, measured primarily through retention and supported by engagement metrics.

### Analytical questions

1. Does moving the gate affect Day 1 retention?
2. Does it improve or reduce Day 7 retention?
3. Does the change meaningfully affect game-round engagement?
4. Is the experiment allocation consistent with the intended 50/50 split?
5. What decision should the product team make given the observed effects and uncertainty?

---

## Dataset

The dataset contains **90,189 player-level observations** from the Cookie Cats experiment.

| Column | Description |
|---|---|
| `userid` | Unique player identifier |
| `version` | Experiment assignment: `gate_30` or `gate_40` |
| `sum_gamerounds` | Total game rounds played during the observation period |
| `retention_1` | Whether the player returned after one day |
| `retention_7` | Whether the player returned after seven days |

The raw CSV is intentionally excluded from this repository. Obtain the dataset separately and save it as:

`data/raw/cookie_cats.csv`

The analysis outputs and visualizations are included where appropriate so that readers can inspect the reported results without committing the raw dataset.

---

## Methodology

The project follows a structured experimentation workflow.

1. **Business framing:** define the decision, control and treatment groups, and retention metrics.
2. **Data ingestion:** load player-level data into PostgreSQL.
3. **Data validation:** inspect row counts, user uniqueness, missing values, experiment groups, negative game rounds, and extreme engagement observations.
4. **SQL analysis:** create analytical views, calculate group-level KPIs, and prepare data for reporting.
5. **Experiment health:** test whether the observed allocation differs from the assumed 50/50 split.
6. **Statistical inference:** compare retention proportions and evaluate game-round engagement.
7. **Uncertainty estimation:** use bootstrap simulation to estimate intervals around retention differences.
8. **Power analysis:** calculate minimum detectable effect (MDE) as part of experiment planning.
9. **Visualization:** build Python charts and a five-page Power BI report.
10. **Decision-making:** synthesize the findings into a product recommendation, including experiment-quality caveats.

---

## Data Quality & Experiment Health

The initial quality checks produced the following results:

| Validation check | Result |
|---|---:|
| Total records | 90,189 |
| Unique player IDs | 90,189 |
| Duplicate user IDs | 0 |
| Missing values | 0 |
| Negative game-round records | 0 |
| Zero-round players | 3,994 |
| Extreme engagement observations flagged | 1 |

One player recorded 49,854 game rounds, substantially above the next-highest observation. The raw record was retained, while the project's analysis logic excluded this extreme observation from the main average-round calculation. This exclusion rule should be considered when reproducing engagement results.

### Sample Ratio Mismatch (SRM)

| Experiment group | Observed players |
|---|---:|
| `gate_30` | 44,700 |
| `gate_40` | 45,489 |
| **Total** | **90,189** |

The SRM test returned **p = 0.0086**, which is below the conventional 0.05 threshold under the assumed 50/50 allocation.

This is an experiment-validity warning. Before making a definitive causal claim, investigate assignment logic, eligibility rules, and event logging. The observed group difference should be interpreted alongside this limitation.

---

## Statistical Results

### 1. Retention Analysis

The treatment-minus-control effect is reported in percentage points (pp).

| Metric | Absolute effect | p-value | Interpretation |
|---|---:|---:|---|
| Day 1 retention | -0.59 pp | 0.0744 | Not statistically significant at 5% |
| Day 7 retention | -0.82 pp | 0.0016 | Statistically significant decline |

Day 7 retention is the primary metric for the product decision because it reflects sustained return behavior.

The treatment group's Day 7 retention was approximately **4.31% lower relative to the control rate**, equivalent to around **8 fewer Day 7 returners per 1,000 players** at the observed rates.

### 2. Bootstrap Uncertainty

Bootstrap analysis was used to estimate uncertainty around the retention effects.

| Metric | 95% bootstrap interval | Bootstrap share above zero |
|---|---:|---:|
| Day 1 retention | [-1.25, 0.06] pp | 3.47% |
| Day 7 retention | [-1.34, -0.31] pp | 0.08% |

The Day 7 interval lies below zero, supporting the conclusion that the observed treatment effect is negative. Day 1's interval includes zero, consistent with its non-significant hypothesis test.

These intervals quantify uncertainty under the bootstrap procedure; they do not resolve the separate SRM concern.

### 3. Engagement Analysis

| Metric | `gate_30` | `gate_40` | Difference |
|---|---:|---:|---:|
| Average game rounds* | 51.34 | 51.30 | -0.04 |
| Median game rounds | 17 | 16 | -1 |

The Mann–Whitney U test returned **p = 0.050892**. The reported rank-biserial effect size was **-0.007504**, indicating a negligible practical difference in the rank-based engagement comparison.

The evidence does not indicate a meaningful engagement benefit that offsets the lower Day 7 retention.

### 4. Minimum Detectable Effect

The notebook includes MDE analysis to support experiment planning. MDE depends on the baseline rate, significance level, statistical power, allocation, and sample size. Consult the notebook's calculations and assumptions when using the result to design a future experiment.

---

## Final Product Recommendation

### Keep the gate at level 30 for now.

The evidence against an immediate level-40 rollout is:

- Day 1 retention declined, although the difference was not statistically significant at the 5% level.
- Day 7 retention declined by 0.82 percentage points, with a p-value of approximately 0.0016.
- Bootstrap uncertainty estimates support a negative Day 7 effect.
- Game-round engagement showed no meaningful practical improvement.
- The SRM warning raises questions about experiment allocation or data collection.

**Recommended next steps**

1. Audit randomization, group assignment, eligibility, and logging.
2. Determine whether the observed SRM can be explained.
3. Re-run the experiment if the imbalance cannot be resolved.
4. Continue using Day 7 retention as the primary decision metric, with engagement and Day 1 retention as supporting metrics.

The current evidence does not support rolling out the level-40 gate. The SRM warning means the result should be validated before a definitive production decision.

---

## Technical Architecture

| Layer | Technology | Purpose |
|---|---|---|
| Data storage | PostgreSQL | Store raw experiment data |
| Data validation | SQL | Check data quality and group allocation |
| Analytical modelling | SQL views | Create player-level and group-level analysis datasets |
| Statistical analysis | Python, Pandas, NumPy, SciPy, Statsmodels | Test retention differences, estimate uncertainty, and analyse engagement |
| Visualization | Matplotlib | Generate statistical and exploratory charts |
| Business intelligence | Power BI | Present KPIs, experiment health, and recommendations |
| Reproducibility | Jupyter Notebook, Git | Document the workflow and version the project |

---

## Repository Structure

```text
cookie-cats-ab-testing/
├── data/
│   ├── raw/                         # Local dataset; excluded from Git
│   └── processed/                   # Statistical summary CSVs
├── images/                          # Generated charts and dashboard previews
├── notebooks/
│   └── 01_ab_testing_analysis.ipynb
├── powerbi/
│   └── Cookie_Cats_AB_Testing_Dashboard.pbix
├── reports/
│   ├── executive_summary.md
│   └── initial_sql_findings.md
├── sql/
│   ├── 01_create_raw_table.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_create_analysis_view.sql
│   ├── 04_experiment_kpis.sql
│   ├── 05_treatment_effects.sql
│   └── 06_powerbi_views.sql
├── .gitignore
├── README.md
└── requirements.txt
```

---

## Run the Project Locally

### Prerequisites

- Python installed
- PostgreSQL installed and running
- Jupyter Notebook support
- Power BI Desktop for the dashboard

### 1. Clone the repository

```bash
git clone https://github.com/RonakGoyal11/cookie-cats-ab-testing.git
cd cookie-cats-ab-testing
```

### 2. Set up Python

Create and activate a virtual environment.

**Windows CMD**

```cmd
python -m venv .venv
.venv\Scripts\activate
python -m pip install -r requirements.txt
```

### 3. Prepare the dataset

Obtain the Cookie Cats CSV separately and place it at:

```text
data/raw/cookie_cats.csv
```

### 4. Create the PostgreSQL database

Open `psql` or another PostgreSQL client and execute:

```sql
CREATE DATABASE cookie_cats_ab;
```

Connect to `cookie_cats_ab` and execute `sql/01_create_raw_table.sql` to create the raw table.

### 5. Load the CSV

In `psql`, use the following command from the project directory, adjusting the absolute path if necessary:

```sql
\copy raw.cookie_cats(userid, version, sum_gamerounds, retention_1, retention_7) FROM 'E:/Analytics-Projects/cookie-cats-ab-testing/data/raw/cookie_cats.csv' WITH (FORMAT csv, HEADER true);
```

Replace the example path with the actual location of your local project. The `\copy` command is a `psql` command, not ordinary SQL.

### 6. Run the SQL scripts

Execute the scripts in order using `psql` or a compatible PostgreSQL client:

1. `sql/01_create_raw_table.sql`
2. `sql/02_data_quality_checks.sql`
3. `sql/03_create_analysis_view.sql`
4. `sql/04_experiment_kpis.sql`
5. `sql/05_treatment_effects.sql`
6. `sql/06_powerbi_views.sql`

Run the table-creation script before loading the CSV. Run the data-quality checks after loading the data.

### 7. Run the Python notebook

Open Jupyter from the project directory:

```bash
python -m jupyter notebook
```

Open `notebooks/01_ab_testing_analysis.ipynb` and execute the analysis cells. If the notebook connects to PostgreSQL, configure the connection values in the notebook or in a local `.env` file, according to its implementation.

Example local environment variables:

```text
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cookie_cats_ab
```

**Do not commit `.env` or database credentials.** The project's `.gitignore` excludes environment files and the raw dataset.

### 8. Open the Power BI report

Open `powerbi/Cookie_Cats_AB_Testing_Dashboard.pbix` in Power BI Desktop. Update the PostgreSQL connection to match your environment, refresh the data, and verify the report visuals.

---

## Skills Demonstrated

- Product analytics and experiment design
- A/B testing and hypothesis testing
- Day 1 and Day 7 retention analysis
- Sample Ratio Mismatch diagnostics
- SQL data modelling and quality checks
- Python statistical analysis
- Bootstrap confidence intervals
- Engagement analysis and effect sizes
- Minimum Detectable Effect analysis
- Power BI dashboard development
- Business interpretation and decision communication
- Git and GitHub version control

---

## Author

**Ronak Goyal**

B.Tech student | Aspiring Business & Product Analytics professional

- GitHub: [RonakGoyal11](https://github.com/RonakGoyal11)
- Project: [Cookie Cats A/B Testing and Experimentation Analysis](https://github.com/RonakGoyal11/cookie-cats-ab-testing)

---

*This is an analytical case study using the available experiment dataset. The conclusions describe the observed results and their statistical uncertainty; the sample-ratio warning should be investigated before treating the findings as definitive causal evidence.*
