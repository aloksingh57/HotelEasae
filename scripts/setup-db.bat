@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo  HostelEase - Smart Hostel Management System: Automated DB Setup
echo =====================================================================
echo.

:: Detect psql binary
if exist "C:\Program Files\PostgreSQL\17\bin\psql.exe" (
    set "PSQL_BIN=C:\Program Files\PostgreSQL\17\bin\psql.exe"
) else (
    set "PSQL_BIN=psql"
)

:: Configuration
set "DB_HOST=localhost"
set "DB_PORT=5433"
set "DB_NAME=hostelease_db"
set "DB_USER=postgres"

echo Target PostgreSQL Host: !DB_HOST!:!DB_PORT!
echo Target Database:        !DB_NAME!
echo Target User:            !DB_USER!
echo.

if "%PGPASSWORD%"=="" (
    set /p PGPASSWORD="Enter password for PostgreSQL user '!DB_USER!': "
)

echo.
echo [1/6] Creating database '!DB_NAME!'...
"!PSQL_BIN!" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -f "database\01_create_database.sql"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to connect or create database. Please verify credentials.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/6] Creating tables and schemas...
"!PSQL_BIN!" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -d !DB_NAME! -f "database\02_create_tables.sql"

echo.
echo [3/6] Applying unique constraints and partial indexes...
"!PSQL_BIN!" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -d !DB_NAME! -f "database\03_constraints_indexes.sql"

echo.
echo [4/6] Seeding facilities, rooms, beds, and academic sessions...
"!PSQL_BIN!" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -d !DB_NAME! -f "database\04_seed_data.sql"

echo.
echo [5/6] Seeding sample accounts with BCrypt hashes...
"!PSQL_BIN!" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -d !DB_NAME! -f "database\05_sample_accounts.sql"

echo.
echo [6/6] Creating analytical views and reports...
"!PSQL_BIN!" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -d !DB_NAME! -f "database\06_reports.sql"

echo.
echo =====================================================================
echo [SUCCESS] Database '!DB_NAME!' initialized and fully seeded!
echo =====================================================================
pause
