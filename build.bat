@echo off
setlocal
echo ========================================================
echo   HostelEase - Compiling and Packaging Maven WAR
echo ========================================================

cd /d "%~dp0"

set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "PATH=C:\Program Files\Java\jdk-26.0.2\bin;C:\tools\apache-maven-3.10.0\bin;%PATH%"

echo Using Java:
"%JAVA_HOME%\bin\java.exe" -version

echo.
echo Running Maven build...
call "C:\tools\apache-maven-3.10.0\bin\mvn.cmd" clean package -DskipTests=true
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Maven build failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] HostelEase.war successfully generated in:
echo   %~dp0target\HostelEase.war
echo ========================================================
pause
