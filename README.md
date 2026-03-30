# 📊 SQL Job Market Analysis — Data Analyst Roles

## Introduction

This project dives into the data analyst job market using SQL to answer real-world career questions: *Which roles pay the most? What skills should I learn? Where do high pay and high demand overlap?*

The dataset contains job postings with salary data, company info, required skills, and remote-work flags — all loaded into a relational PostgreSQL database and queried across 5 structured analyses.

---
📊 Dataset files
👉 **[Open Google Drive Folder](https://drive.google.com/drive/folders/1moeWYoUtUklJO6NJdWo9OV8zWjRn0rjN)**
---

## 🛠️ Tools I Used

| Tool | Purpose |
|------|---------|
| **PostgreSQL** | Core database engine for running all queries |
| **SQL** | Primary language for all data exploration and analysis |
| **CTEs & Subqueries** | Used to structure complex multi-step logic cleanly |
| **Aggregate Functions** | `COUNT()`, `AVG()`, `ROUND()` for summarising job and salary data |
| **JOINs** | `INNER JOIN`, `LEFT JOIN` across 4 relational tables |
| **Git & GitHub** | Version control and project hosting |

**Database Schema:**
- `job_postings_fact` — core job listings (salary, location, schedule, remote flag)
- `company_dim` — company names and metadata
- `skills_dim` — skill names and categories
- `skills_job_dim` — bridge table linking jobs to required skills

---

## 📂 The Analysis

### 1. Top Paying Data Analyst Jobs
**File:** `project_sql/1_top_paying_job.sql`

Filtered remote Data Analyst roles where salary was specified, then joined with `company_dim` to surface the top 10 highest-paying positions.

```sql
SELECT job_id, com_name.name AS COMPANY_NAME, job_title,
       job_location, job_schedule_type, salary_year_avg, job_posted_date
FROM job_postings_fact
LEFT JOIN company_dim AS com_name ON com_name.company_id = job_postings_fact.company_id
WHERE job_title_short = 'Data Analyst' AND job_location = 'Anywhere'
      AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```

> 💡 Top result: AT&T's *Associate Director – Data Insights* at **$255,829/year**

---

### 2. Skills Required for Top Paying Jobs
**File:** `project_sql/2_top paying_skill.sql`

Used a CTE to first isolate the top 10 highest-paying remote roles, then joined with the skills tables to reveal what skills those jobs required.

```sql
WITH top_paying_job AS (
  SELECT job_id, com_name.name AS COMPANY_NAME, job_title,
         salary_year_avg, job_posted_date::date
  FROM job_postings_fact
  LEFT JOIN company_dim AS com_name ON com_name.company_id = job_postings_fact.company_id
  WHERE job_title_short = 'Data Analyst' AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
  ORDER BY salary_year_avg DESC LIMIT 10
)
SELECT top_paying_job.*, skills
FROM top_paying_job
INNER JOIN skills_job_dim ON skills_job_dim.job_id = top_paying_job.job_id
INNER JOIN skills_dim AS skill_job ON skill_job.skill_id = skills_job_dim.skill_id
ORDER BY salary_year_avg DESC;
```

> 💡 **SQL (8×), Python (7×), Tableau (6×)** — the non-negotiable trio for top-paying roles.

---

### 3. Most In-Demand Skills
**File:** `project_sql/3_top_demand_skills.sql`

Counted how frequently each skill appeared across *all* remote Data Analyst postings to find what the market actually wants most.

```sql
SELECT skills, COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
INNER JOIN skills_dim AS skill_job ON skill_job.skill_id = skills_job_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND job_work_from_home = TRUE
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5;
```

> 💡 Top 5 in-demand skills: **SQL, Excel, Python, Tableau, Power BI**

---

### 4. Top Paying Skills
**File:** `project_sql/4_top_paying_skill.sql`

Calculated the average salary associated with each skill across all Data Analyst roles with specified salaries — regardless of location.

```sql
SELECT skills, ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25;
```

> 💡 Highest-paying skills: **SVN ($400K), Solidity ($179K), Couchbase ($160K)** — niche/specialist tools command a premium.

---

### 5. Most Optimal Skills (High Demand + High Pay)
**File:** `project_sql/5_optimal_skills.sql`

Combined demand count and average salary into one query to identify the sweet spot — skills that are both widely required *and* well-compensated, using both a CTE approach and a cleaner single-query rewrite.

```sql
SELECT skills_dim.skills,
       COUNT(skills_job_dim.job_id) AS demand_count,
       ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
      AND job_work_from_home = True
GROUP BY skills_dim.skill_id
HAVING COUNT(skills_job_dim.job_id) > 10
ORDER BY avg_salary DESC, demand_count DESC
LIMIT 25;
```

> 💡 Skills like **Python, Tableau, and SQL** balance both dimensions — high demand AND strong salaries. The true "learn these first" list.

---


## 💡 What I Learned

- **CTEs make complex queries readable** — breaking a multi-step problem into named subqueries (like isolating top-paying jobs before joining skills) is far cleaner than nested subqueries.
- **JOINs are the backbone of relational analysis** — this project reinforced how bridge/junction tables (`skills_job_dim`) connect entities and enable many-to-many relationships in SQL.
- **`HAVING` vs `WHERE`** — filtering *after* aggregation with `HAVING` (e.g., `demand_count > 10`) is essential when working with grouped results.
- **Niche skills ≠ practical skills** — SVN topped salary charts but appears in almost zero job listings. High average salary can be misleading without pairing it with demand count.
- **Remote job filtering** — `job_work_from_home = TRUE` vs `job_location = 'Anywhere'` behave differently and affect results; understanding your filters matters.

---

## ✅ Conclusion

This SQL analysis reveals a clear roadmap for anyone targeting Data Analyst roles:

- **Must-learn foundation:** SQL, Python, Excel — high demand across all seniority levels
- **Visualisation layer:** Tableau and Power BI are consistently required and well-paid
- **Salary ceiling:** Niche tools (Kafka, PyTorch, Terraform) appear in fewer roles but push average salaries significantly higher
- **Optimal investment:** Skills like Python and Tableau offer the best balance of job availability and compensation — the real "bang for your buck" upskilling targets

The project demonstrates how structured SQL queries — from simple filters to multi-CTE pipelines — can turn raw job posting data into actionable career intelligence.
