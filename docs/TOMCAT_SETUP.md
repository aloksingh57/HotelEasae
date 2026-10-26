# Apache Tomcat 10.1 Deployment & Production Configuration Guide

## 1. System Requirements & Compatibility
- **Server Software**: Apache Tomcat 10.1.x (strictly required for Jakarta EE 10 / Servlet 6.0).
  > **Note**: Do not deploy on Tomcat 9.x or earlier, as Tomcat 9 utilizes legacy `javax.servlet.*` packages while HostelEase is modern `jakarta.servlet.*`.
- **Java Runtime**: JDK 17 LTS or higher.
- **Operating System**: Windows Server / Windows 10/11 or Linux.

---

## 2. Directory Layout & Environment Setup

### Environment Variables
Configure the following system environment variables:
1. `JAVA_HOME`: Path to your JDK 17+ (e.g. `C:\Program Files\Java\jdk-26.0.2` or `C:\Program Files\Java\jdk-17`).
2. `CATALINA_HOME`: Path to your Apache Tomcat 10.1 directory (e.g. `C:\apache-tomcat-10.1` or `C:\Program Files\Apache Software Foundation\Tomcat 10.1`).
3. Append `%JAVA_HOME%\bin` and `%CATALINA_HOME%\bin` to your system `PATH`.

### Tuning Tomcat Memory (`setenv.bat`)
In production, create or edit `%CATALINA_HOME%\bin\setenv.bat` with the following memory parameters:
```bat
set "JAVA_OPTS=-Xms512m -Xmx2048m -XX:+UseG1GC -Dfile.encoding=UTF-8"
```

---

## 3. WAR Deployment Options

### Option A: Automated One-Click Deployment (Recommended)
From the project root directory, run the provided deployment script:
```bat
scripts\deploy-to-tomcat.bat
```
This script will:
1. Verify `target\HostelEase.war` exists (or compile it automatically).
2. Detect your Tomcat installation.
3. Deploy `HostelEase.war` directly into `%CATALINA_HOME%\webapps\`.

### Option B: Manual File Copy
1. Build the production package:
   ```bat
   scripts\build.bat
   ```
2. Copy `target\HostelEase.war` into:
   ```
   %CATALINA_HOME%\webapps\HostelEase.war
   ```
3. Start or restart Tomcat:
   ```bat
   %CATALINA_HOME%\bin\startup.bat
   ```
4. Tomcat will automatically unpack the WAR archive into `%CATALINA_HOME%\webapps\HostelEase\`.

---

## 4. Production Database Configuration
HostelEase resolves database and SMTP settings with the following fallback precedence:
1. **OS Environment Variables**: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`.
2. **`application.properties`**: Located in `src/main/resources/application.properties` bundled inside the WAR.
3. **External Override File**: You can place an external `application.properties` in Tomcat's classpath (`%CATALINA_HOME%\lib\application.properties`).

Example Production Environment Variables:
```bat
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=hostelease_db
set DB_USER=postgres
set DB_PASSWORD=YourSecureProductionPassword
```

---

## 5. Verifying Deployment & Access URLs
Once Tomcat is running, open your browser and navigate to:
```
http://localhost:8080/HostelEase/
```
- **Login URL**: `http://localhost:8080/HostelEase/login`
- **Health Check Endpoint**: `http://localhost:8080/HostelEase/health` (Returns JSON database connectivity and pool status).

### Log Inspection
Check the following logs for diagnostics:
- **Application Logs**: `%CATALINA_HOME%\logs\hostelease.log`
- **Tomcat Cataline Log**: `%CATALINA_HOME%\logs\catalina.YYYY-MM-DD.log`
- **Localhost Log**: `%CATALINA_HOME%\logs\localhost.YYYY-MM-DD.log`
