# HostelEase — Production Deployment Guide

## 1. Prerequisites
- **Target OS**: Linux (Ubuntu 22.04 LTS / Debian 12 / RHEL 9) or Windows Server 2022.
- **Java Runtime**: OpenJDK 17 LTS or higher.
- **Web Container**: Apache Tomcat 10.1.x (compatible with Jakarta EE 10 / Servlet 6.0).
- **Database Server**: PostgreSQL 17.x with persistent storage.
- **Reverse Proxy**: Nginx or Apache HTTP Server with Let's Encrypt SSL/TLS certificate.

---

## 2. Step-by-Step Production Deployment

### Step 1: Database Provisioning
Connect to PostgreSQL and create the production database and non-root application user:
```sql
CREATE USER hostelease_app WITH PASSWORD 'your_strong_production_password_here';
CREATE DATABASE hostelease_db OWNER hostelease_app ENCODING 'UTF8';
GRANT ALL PRIVILEGES ON DATABASE hostelease_db TO hostelease_app;
```
Execute the migration scripts in sequence:
```bash
psql -h localhost -p 5432 -U hostelease_app -d hostelease_db -f database/02_create_tables.sql
psql -h localhost -p 5432 -U hostelease_app -d hostelease_db -f database/03_constraints_indexes.sql
psql -h localhost -p 5432 -U hostelease_app -d hostelease_db -f database/04_seed_data.sql
psql -h localhost -p 5432 -U hostelease_app -d hostelease_db -f database/06_reports.sql
```

### Step 2: Tomcat 10.1 Configuration
In Tomcat's `bin/setenv.sh` (or `bin/setenv.bat` on Windows), configure environment variables:
```bash
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export DB_HOST="localhost"
export DB_PORT="5432"
export DB_NAME="hostelease_db"
export DB_USER="hostelease_app"
export DB_PASSWORD="your_strong_production_password_here"
export APP_ENV="PRODUCTION"
export MAIL_ENABLED="true"
export MAIL_HOST="smtp.sendgrid.net"
export MAIL_PORT="587"
export MAIL_USERNAME="apikey"
export MAIL_PASSWORD="your_sendgrid_api_key"
export MAIL_FROM="Hostel Administration <no-reply@yourcampus.edu>"
```

### Step 3: WAR Deployment
1. Build the production WAR package:
   ```bash
   mvn clean package -DskipTests=false
   ```
2. Copy `target/HostelEase.war` into `$CATALINA_HOME/webapps/HostelEase.war`.
3. Restart or start Tomcat:
   ```bash
   systemctl restart tomcat10
   ```

### Step 4: Health Verification
Execute curl against the health check endpoint:
```bash
curl -I http://localhost:8080/HostelEase/health
```
Expected output:
```json
{"status":"HEALTHY","database_reachable":true,"query_execution":true,"tables_detected":30}
```
