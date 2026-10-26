@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo  HostelEase - Smart Hostel Management System: Environment Verification
echo =====================================================================
echo.

:: 1. Verify Java Environment
echo [1/4] Checking Java Runtime & Compiler...
where javac >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] javac found on PATH:
    javac -version
) else (
    if exist "C:\Program Files\Java\jdk-26.0.2\bin\javac.exe" (
        echo [OK] JDK located at default system installation:
        "C:\Program Files\Java\jdk-26.0.2\bin\javac.exe" -version
        set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
        set "PATH=!JAVA_HOME!\bin;!PATH!"
    ) else (
        echo [ERROR] JDK compiler 'javac' was not found. Please install Java 17+ or set JAVA_HOME.
    )
)
echo.

:: 2. Verify Apache Maven
echo [2/4] Checking Apache Maven...
where mvn >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Maven found on PATH:
    mvn -version
) else (
    if exist "C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd" (
        echo [OK] Maven located in user downloads directory:
        "C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd" -version
        set "PATH=C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin;!PATH!"
    ) else (
        echo [ERROR] Maven not found. Please ensure Maven 3.8+ is installed.
    )
)
echo.

:: 3. Verify PostgreSQL 17 Service & Connection
echo [3/4] Checking PostgreSQL Database Service...
sc query postgresql-x64-17 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Service 'postgresql-x64-17' is installed on this Windows host.
) else (
    echo [INFO] Windows service 'postgresql-x64-17' query returned non-zero. Checking CLI...
)

if exist "C:\Program Files\PostgreSQL\17\bin\psql.exe" (
    echo [OK] psql.exe located at: "C:\Program Files\PostgreSQL\17\bin\psql.exe"
    "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -c "SELECT 'HostelEase Database Connection Successful!' AS status;" 2>nul
) else (
    echo [INFO] Attempting psql from PATH...
    psql -U postgres -d hostelease_db -c "SELECT 'HostelEase Database Connection Successful!' AS status;" 2>nul
)
echo.

:: 4. Verify Apache Tomcat 10.x
echo [4/4] Checking Apache Tomcat 10.x...
if exist "C:\apache-tomcat-10.1" (
    echo [OK] Tomcat 10.1 located at: C:\apache-tomcat-10.1
) else if exist "C:\Program Files\Apache Software Foundation\Tomcat 10.1" (
    echo [OK] Tomcat 10.1 located at: C:\Program Files\Apache Software Foundation\Tomcat 10.1
) else (
    echo [INFO] Standard Tomcat locations checked. You can specify CATALINA_HOME environment variable.
)

echo.
echo =====================================================================
echo  Verification Completed. All prerequisite layers checked.
echo =====================================================================
pause
