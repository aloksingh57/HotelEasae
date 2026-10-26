# HostelEase — Caching & CDN Delivery Strategy

## 1. Caching Policy Overview
HostelEase strictly delineates public static assets from private, authenticated institutional records.

---

## 2. Public Static Assets (Eligible for CDN & Browser Caching)
- **CSS Stylesheets**: `/assets/css/style.css`
- **JavaScript Scripts**: `/assets/js/main.js`, `/assets/js/chart-init.js`
- **Third-Party CDNs**:
  - Bootstrap 5.3.3: `cdn.jsdelivr.net`
  - Bootstrap Icons 1.11.3: `cdn.jsdelivr.net`
  - Chart.js 4.4.3: `cdn.jsdelivr.net`
  - Google Fonts (Outfit, Plus Jakarta Sans): `fonts.googleapis.com`

### Cache-Control Headers for Static Assets:
```http
Cache-Control: public, max-age=604800, immutable
```

---

## 3. Dynamic & Authenticated Endpoints (Strictly NON-Cacheable)
To prevent information leakage and stale occupancy records, the following endpoints MUST NEVER be cached by proxies or CDNs:
- `/admin/*`, `/warden/*`, `/student/*`
- `/login`, `/logout`, `/health`
- Leave approvals, fee payment records, visitor logs, room occupancy views

### Security Headers applied via SecurityFilter:
```http
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
Expires: 0
```
Occupancy and allocation decisions MUST ALWAYS query PostgreSQL 17 authoritative tables directly with proper transaction locks.
