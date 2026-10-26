@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo  HostelEase - Smart Hostel Management System: Maven Clean & Package
echo =====================================================================
echo.

:: Locate JDK
if exist "C:\Program Files\Java\jdk-26.0.2" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
    set "PATH=!JAVA_HOME!\bin;!PATH!"
)

:: Locate Maven
if exist "C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd" (
    set "MVN_CMD=C:\Users\Lenovo\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd"
) else (
    set "MVN_CMD=mvn"
)

echo Using Java:
java -version
echo.
echo Using Maven:
call !MVN_CMD! -version
echo.

echo Compiling Java 17 Jakarta EE 10 codebase and packaging WAR archive...
call !MVN_CMD! package -DskipTests=false

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =====================================================================
    echo [SUCCESS] Build completed! WAR archive created:
    echo           target\HostelEase.war
    echo =====================================================================
) else (
    echo.
    echo [ERROR] Build failed. Please inspect compiler errors above.
)

pause
