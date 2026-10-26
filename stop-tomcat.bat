@echo off
setlocal
echo ========================================================
echo   HostelEase - Stopping Apache Tomcat
echo ========================================================

call "C:\apache-tomcat-10.1\bin\shutdown.bat" 2>nul

rem Force kill any process holding port 8080
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8080" ^| findstr "LISTENING"') do (
    echo Terminating PID %%a on port 8080...
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo [DONE] Tomcat stopped and port 8080 released.
echo ========================================================
pause
