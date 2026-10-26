-- ============================================================================
-- SCRIPT 01: DATABASE CREATION SCRIPT FOR HOSTELEASE
-- ============================================================================
-- NOTE FOR DEVELOPER / ADMINISTRATOR:
-- 1. Execute this file while connected to the default 'postgres' maintenance database.
--    Command (CLI):
--      psql -U postgres -f 01_create_database.sql
-- 2. Once this database is created, connect to 'hostelease_db' to run scripts 02 through 06.
--    Command (CLI):
--      psql -U postgres -d hostelease_db -f 02_create_tables.sql
-- ============================================================================

-- Terminate active connections if database exists (safe re-creation if needed)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'hostelease_db' AND pid <> pg_backend_pid();

-- Drop if exists (optional safety; commented out by default)
-- DROP DATABASE IF EXISTS hostelease_db;

-- Create database with UTF-8 encoding
CREATE DATABASE hostelease_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE hostelease_db IS 'HostelEase Smart Hostel Management System Database';
