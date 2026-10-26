@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo  HostelEase - Smart Hostel Management System: Deploy to Apache Tomcat
echo =====================================================================
echo.

set "WAR_FILE=target\HostelEase.war"
if not exist "%WAR_FILE%" (
    echo [INFO] target\HostelEase.war not found. Building now...
    call scripts\build.bat
)

if not exist "%WAR_FILE%" (
    echo [ERROR] Build did not produce target\HostelEase.war. Aborting deployment.
    pause
    exit /b 1
)

:: Check for Tomcat installation
set "TARGET_TOMCAT="
if defined CATALINA_HOME (
    set "TARGET_TOMCAT=%CATALINA_HOME%"
) else if exist "C:\apache-tomcat-10.1" (
    set "TARGET_TOMCAT=C:\apache-tomcat-10.1"
) else if exist "C:\Program Files\Apache Software Foundation\Tomcat 10.1" (
    set "TARGET_TOMCAT=C:\Program Files\Apache Software Foundation\Tomcat 10.1"
)

if "%TARGET_TOMCAT%"=="" (
    echo [WARNING] Automatic Tomcat directory could not be resolved.
    echo Please copy %WAR_FILE% manually into your Tomcat's 'webapps' folder.
    pause
    exit /b 0
)

echo Found Tomcat directory at: %TARGET_TOMCAT%
echo Copying %WAR_FILE% to: %TARGET_TOMCAT%\webapps\HostelEase.war ...

copy /Y "%WAR_FILE%" "%TARGET_TOMCAT%\webapps\HostelEase.war"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =====================================================================
    echo [SUCCESS] HostelEase.war deployed to Tomcat webapps!
    echo Access URL: http://localhost:8080/HostelEase/
    echo =====================================================================
) else (
    echo.
    echo [ERROR] Failed to copy WAR file. Ensure Tomcat has write permissions or stop the service before copying.
)

pause
