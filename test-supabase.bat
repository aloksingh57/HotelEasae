@echo off
setlocal
echo ========================================================
echo   HostelEase - Supabase Live Connection Diagnostic
echo ========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { $res = Invoke-RestMethod -Uri 'http://localhost:8080/HostelEase/api/diagnostics/db' -TimeoutSec 5; Write-Host ('STATUS:         ' + $res.status) -ForegroundColor Green; Write-Host ('BACKEND:        ' + $res.backend); Write-Host ('HOST:           ' + $res.host + ':' + $res.port); Write-Host ('DATABASE:       ' + $res.database); Write-Host ('CONNECTED USER: ' + $res.connectedUser); Write-Host ('SSL MODE:       ' + $res.sslMode); Write-Host ('LATENCY:        ' + $res.latencyMs + ' ms'); Write-Host ('ACTIVE USERS:   ' + $res.activeUsersCount); Write-Host ('ACTIVE HOSTELS: ' + $res.activeHostelsCount); } catch { Write-Host 'Tomcat is not responding on http://localhost:8080/HostelEase' -ForegroundColor Red; Write-Host 'Please run start-tomcat.bat first.' -ForegroundColor Yellow; }"
echo.
echo ========================================================
pause
