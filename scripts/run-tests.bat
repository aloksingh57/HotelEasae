@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo  HostelEase - Smart Hostel Management System: Automated Test Suite
echo =====================================================================
echo.

if exist "C:\Program Files\Java\jdk-26.0.2" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
    set "PATH=!JAVA_HOME!\bin;!PATH!"
)

if exist "C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd" (
    set "MVN_CMD=C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd"
) else (
    set "MVN_CMD=mvn"
)

echo Running JUnit 5 integration and unit test suite against PostgreSQL 17...
call !MVN_CMD! test

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =====================================================================
    echo [SUCCESS] All automated tests passed cleanly!
    echo =====================================================================
) else (
    echo.
    echo [ERROR] Tests failed. Check target\surefire-reports for failure details.
)

pause
