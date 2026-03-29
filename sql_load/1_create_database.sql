CREATE DATABASE sql_cources;



SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname='sql_cources' AND pid<> pg_backend_pid();

DROP DATABASE IF EXISTS sql_cources;