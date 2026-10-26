@echo off
setlocal
echo ========================================================
echo   HostelEase - Starting Apache Tomcat 10 with Supabase
echo ========================================================

cd /d "%~dp0"

set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "JRE_HOME=C:\Program Files\Java\jdk-26.0.2"
set "CATALINA_HOME=C:\apache-tomcat-10.1"
set "CATALINA_BASE=C:\apache-tomcat-10.1"

rem Check if WAR exists, if not build it
if not exist "%~dp0target\HostelEase.war" (
    echo Building WAR first...
    call "%~dp0build.bat"
)

echo Deploying latest HostelEase.war to Tomcat webapps...
copy /y "%~dp0target\HostelEase.war" "C:\apache-tomcat-10.1\webapps\HostelEase.war" >nul

rem Check if port 8080 is already active
netstat -aon | findstr ":8080" | findstr "LISTENING" >nul
if %ERRORLEVEL% EQU 0 (
    echo Tomcat is already running on port 8080.
    echo Opening application directly: http://localhost:8080/HostelEase/
    start http://localhost:8080/HostelEase/
    exit /b 0
)

echo Starting Tomcat...
cd /d "C:\apache-tomcat-10.1\bin"
start "Apache Tomcat (HostelEase)" /d "C:\apache-tomcat-10.1\bin" "C:\apache-tomcat-10.1\bin\catalina.bat" run

echo Waiting 6 seconds for application startup...
timeout /t 6 /nobreak >nul

echo Opening browser at http://localhost:8080/HostelEase/ ...
start http://localhost:8080/HostelEase/
