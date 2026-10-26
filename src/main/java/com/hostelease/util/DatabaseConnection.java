package com.hostelease.util;

import com.hostelease.config.DatabaseConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * Enterprise Supabase PostgreSQL Connection Utility.
 * 
 * Provides safe, robust database connectivity for HostelEase using either
 * high-performance connection pooling (HikariCP) or direct JDBC connections.
 * 
 * Reads configuration from standardized environment variables:
 * - SUPABASE_DB_HOST
 * - SUPABASE_DB_PORT
 * - SUPABASE_DB_NAME
 * - SUPABASE_DB_USER
 * - SUPABASE_DB_PASSWORD
 * - SUPABASE_DB_SSLMODE
 * 
 * Includes security hardening:
 * - Credentials and passwords are NEVER printed or logged.
 * - Resource cleanup helpers (closeQuietly) for safe JDBC operations.
 * - Meaningful error messages for diagnostics without exposing sensitive data.
 */
public class DatabaseConnection {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConnection.class);

    // Static initialization to register PostgreSQL driver
    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            logger.error("PostgreSQL JDBC Driver not found on classpath: {}", e.getMessage());
        }
    }

    /**
     * Obtains a managed database connection from the connection pool.
     * This is the recommended method for application request processing.
     *
     * @return Connection from the pool
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return DatabaseConfig.getConnection();
    }

    /**
     * Creates a new direct standalone Connection using DriverManager.
     * Useful for standalone scripts, migrations, and low-level diagnostic tests.
     * Callers MUST close this connection (prefer try-with-resources).
     *
     * @return Direct JDBC Connection
     * @throws SQLException if connection fails
     */
    public static Connection getDirectConnection() throws SQLException {
        ConfigInfo cfg = loadConfig();
        validateConfig(cfg);

        String jdbcUrl = buildJdbcUrl(cfg);
        logger.info("Opening direct Supabase JDBC connection to host: {}, db: {}, sslmode: {}", 
                cfg.host, cfg.dbName, cfg.sslMode);

        try {
            return DriverManager.getConnection(jdbcUrl, cfg.user, cfg.password);
        } catch (SQLException e) {
            String sanitizedError = sanitizeErrorMessage(e.getMessage(), cfg.password);
            logger.error("Failed to establish direct Supabase connection to {}:{}/{} (user: {}): {}",
                    cfg.host, cfg.port, cfg.dbName, cfg.user, sanitizedError);
            throw new SQLException("Supabase database connection failed: " + sanitizedError, e.getSQLState(), e.getErrorCode());
        }
    }

    /**
     * Builds the standard PostgreSQL JDBC URL.
     * Format: jdbc:postgresql://HOST:PORT/DATABASE?sslmode=require&ApplicationName=HostelEase
     */
    public static String buildJdbcUrl(ConfigInfo cfg) {
        return String.format("jdbc:postgresql://%s:%s/%s?sslmode=%s&ApplicationName=HostelEase",
                cfg.host, cfg.port, cfg.dbName, cfg.sslMode);
    }

    /**
     * Executes a safe diagnostic read-only query (SELECT 1) and verifies connectivity.
     *
     * @return DiagnosticResult with connectivity status, latency, and sanitized metadata
     */
    public static DiagnosticResult testConnection() {
        long startTime = System.currentTimeMillis();
        ConfigInfo cfg = loadConfig();

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            long latencyMs = System.currentTimeMillis() - startTime;
            int selectOneResult = 0;
            String currentDb = "";
            String currentUser = "";

            try (ResultSet rs = stmt.executeQuery("SELECT 1 AS test_val, current_database(), current_user")) {
                if (rs.next()) {
                    selectOneResult = rs.getInt("test_val");
                    currentDb = rs.getString(2);
                    currentUser = rs.getString(3);
                }
            }

            int userCount = 0;
            try (ResultSet rs = stmt.executeQuery("SELECT count(*) FROM users")) {
                if (rs.next()) {
                    userCount = rs.getInt(1);
                }
            }

            int hostelCount = 0;
            try (ResultSet rs = stmt.executeQuery("SELECT count(*) FROM hostels")) {
                if (rs.next()) {
                    hostelCount = rs.getInt(1);
                }
            }

            return new DiagnosticResult(
                    true,
                    "Supabase connection successful. Database responsive.",
                    cfg.host,
                    cfg.port,
                    currentDb,
                    currentUser,
                    cfg.sslMode,
                    latencyMs,
                    selectOneResult == 1,
                    userCount,
                    hostelCount
            );

        } catch (Exception e) {
            long latencyMs = System.currentTimeMillis() - startTime;
            String sanitized = sanitizeErrorMessage(e.getMessage(), cfg.password);
            logger.error("Supabase diagnostic connection test failed: {}", sanitized);
            return new DiagnosticResult(
                    false,
                    "Supabase connection test failed: " + sanitized,
                    cfg.host,
                    cfg.port,
                    cfg.dbName,
                    cfg.user,
                    cfg.sslMode,
                    latencyMs,
                    false,
                    0,
                    0
            );
        }
    }

    /**
     * Safely closes one or more JDBC/AutoCloseable resources without throwing exceptions.
     */
    public static void closeQuietly(AutoCloseable... resources) {
        if (resources == null) return;
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    logger.debug("Error while quietly closing resource: {}", e.getMessage());
                }
            }
        }
    }

    /**
     * Sanitizes error messages by masking any occurrence of the password.
     */
    private static String sanitizeErrorMessage(String message, String password) {
        if (message == null) return "Unknown database error";
        if (password != null && !password.trim().isEmpty() && message.contains(password)) {
            return message.replace(password, "******");
        }
        return message;
    }

    /**
     * Validates that essential configuration parameters are present.
     */
    private static void validateConfig(ConfigInfo cfg) {
        if (cfg.host == null || cfg.host.trim().isEmpty()) {
            throw new IllegalStateException("Database host is missing. Set SUPABASE_DB_HOST or DB_HOST.");
        }
        if (cfg.user == null || cfg.user.trim().isEmpty()) {
            throw new IllegalStateException("Database user is missing. Set SUPABASE_DB_USER or DB_USER.");
        }
        if (cfg.password == null || cfg.password.trim().isEmpty()) {
            throw new IllegalStateException("Database password is missing. Set SUPABASE_DB_PASSWORD or DB_PASSWORD.");
        }
    }

    /**
     * Loads database configuration with fallback hierarchy:
     * 1. SUPABASE_DB_* environment variables (Highest priority)
     * 2. DB_* environment variables
     * 3. .env file
     * 4. application.properties (Classpath fallback)
     */
    public static ConfigInfo loadConfig() {
        Properties props = new Properties();

        // 1. Classpath application.properties
        try (InputStream in = DatabaseConnection.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception ignored) {}

        // 2. .env in working directory
        File envFile = new File(".env");
        if (envFile.exists()) {
            try (FileInputStream fis = new FileInputStream(envFile)) {
                Properties envProps = new Properties();
                envProps.load(fis);
                props.putAll(envProps);
            } catch (Exception ignored) {}
        }

        // 3. Resolve with SUPABASE_DB_* priority
        String host = resolveVar("SUPABASE_DB_HOST", "DB_HOST", props.getProperty("supabase.db.host", props.getProperty("db.host", "localhost")));
        String port = resolveVar("SUPABASE_DB_PORT", "DB_PORT", props.getProperty("supabase.db.port", props.getProperty("db.port", "5432")));
        String dbName = resolveVar("SUPABASE_DB_NAME", "DB_NAME", props.getProperty("supabase.db.name", props.getProperty("db.name", "postgres")));
        String user = resolveVar("SUPABASE_DB_USER", "DB_USER", props.getProperty("supabase.db.user", props.getProperty("db.user", "postgres")));
        String password = resolveVar("SUPABASE_DB_PASSWORD", "DB_PASSWORD", props.getProperty("supabase.db.password", props.getProperty("db.password", "")));
        String sslMode = resolveVar("SUPABASE_DB_SSLMODE", "DB_SSLMODE", props.getProperty("supabase.db.sslmode", props.getProperty("db.sslmode", "require")));

        return new ConfigInfo(host, port, dbName, user, password, sslMode);
    }

    private static String resolveVar(String supabaseEnvKey, String legacyEnvKey, String fallback) {
        String val = System.getenv(supabaseEnvKey);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }
        val = System.getenv(legacyEnvKey);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }
        return fallback;
    }

    // Immutable configuration holder
    public static class ConfigInfo {
        public final String host;
        public final String port;
        public final String dbName;
        public final String user;
        public final String password;
        public final String sslMode;

        public ConfigInfo(String host, String port, String dbName, String user, String password, String sslMode) {
            this.host = host;
            this.port = port;
            this.dbName = dbName;
            this.user = user;
            this.password = password;
            this.sslMode = sslMode;
        }
    }

    // Safe diagnostic test summary (no secret fields)
    public static class DiagnosticResult {
        public final boolean success;
        public final String message;
        public final String host;
        public final String port;
        public final String database;
        public final String user;
        public final String sslMode;
        public final long latencyMs;
        public final boolean selectOneOk;
        public final int userCount;
        public final int hostelCount;

        public DiagnosticResult(boolean success, String message, String host, String port, String database,
                                String user, String sslMode, long latencyMs, boolean selectOneOk,
                                int userCount, int hostelCount) {
            this.success = success;
            this.message = message;
            this.host = host;
            this.port = port;
            this.database = database;
            this.user = user;
            this.sslMode = sslMode;
            this.latencyMs = latencyMs;
            this.selectOneOk = selectOneOk;
            this.userCount = userCount;
            this.hostelCount = hostelCount;
        }
    }
}
