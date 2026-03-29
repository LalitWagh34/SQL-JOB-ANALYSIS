/*
Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst roles that are available remotely
- Focuses on job postings with specified salaries (remove nulls)
- BONUS: Include company names of top 10 roles
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment options and location flexibility.
    -helping job seekers to understand which skills to develop that align with top salaries 
*/





SELECT 
    job_id ,
    com_name.name AS COMPANY_NAME,
    job_title ,
    job_location ,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM 
    job_postings_fact
LEFT JOIN company_dim AS com_name ON com_name.company_id = job_postings_fact.company_id
WHERE
    job_title_short = 'Data Analyst' AND job_location = 'Anywhere' AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10



/*
    These are the absolute must-haves—they appear most frequently:

SQL (8 times) → 🥇 Most important skill
Python (7 times) → Nearly mandatory
Tableau (6 times) → Top visualization tool

👉 Insight:

If you don’t know SQL + Python + Tableau, you are not competitive for most roles.
SQL is still more demanded than Python for analysts
*/

