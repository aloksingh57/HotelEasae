package com.hostelease.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * Enterprise Database Connection Management using HikariCP connection pool.
 * Loads configuration from Environment Variables, .env file, or classpath application.properties.
 */
public class DatabaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);
    private static HikariDataSource dataSource;

    static {
        try {
            initDataSource();
        } catch (Exception e) {
            logger.warn("Initial DataSource initialization deferred: {}", e.getMessage());
        }
    }

    public static synchronized void initDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }

        try {
            Properties props = new Properties();

            // 1. Load from classpath application.properties
            try (InputStream in = DatabaseConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
                if (in != null) {
                    props.load(in);
                }
            } catch (Exception e) {
                logger.warn("Could not load application.properties from classpath: {}", e.getMessage());
            }

            // 2. Load from .env if present in current directory
            File envFile = new File(".env");
            if (envFile.exists()) {
                try (FileInputStream fis = new FileInputStream(envFile)) {
                    Properties envProps = new Properties();
                    envProps.load(fis);
                    props.putAll(envProps);
                } catch (Exception e) {
                    logger.warn("Could not load .env file: {}", e.getMessage());
                }
            }

            // 3. Environment variables take highest precedence (SUPABASE_DB_* first, then DB_*)
            String host = getVal(System.getenv("SUPABASE_DB_HOST"), getVal(System.getenv("DB_HOST"), props.getProperty("supabase.db.host", props.getProperty("db.host", "localhost"))));
            String port = getVal(System.getenv("SUPABASE_DB_PORT"), getVal(System.getenv("DB_PORT"), props.getProperty("supabase.db.port", props.getProperty("db.port", "5432"))));
            String dbName = getVal(System.getenv("SUPABASE_DB_NAME"), getVal(System.getenv("DB_NAME"), props.getProperty("supabase.db.name", props.getProperty("db.name", "postgres"))));
            String user = getVal(System.getenv("SUPABASE_DB_USER"), getVal(System.getenv("DB_USER"), props.getProperty("supabase.db.user", props.getProperty("db.user", "postgres"))));
            String password = getVal(System.getenv("SUPABASE_DB_PASSWORD"), getVal(System.getenv("DB_PASSWORD"), props.getProperty("supabase.db.password", props.getProperty("db.password", ""))));
            String sslMode = getVal(System.getenv("SUPABASE_DB_SSLMODE"), getVal(System.getenv("DB_SSLMODE"), props.getProperty("supabase.db.sslmode", props.getProperty("db.sslmode", "require"))));

            int maxPoolSize = Integer.parseInt(getVal(System.getenv("DB_MAX_POOL_SIZE"), props.getProperty("db.pool.max", "10")));
            int minIdle = Integer.parseInt(getVal(System.getenv("DB_MIN_IDLE"), props.getProperty("db.pool.min", "2")));

            String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s?sslmode=%s&ApplicationName=HostelEase", host, port, dbName, sslMode);

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("org.postgresql.Driver");
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(user);
            config.setPassword(password);

            config.setMaximumPoolSize(maxPoolSize);
            config.setMinimumIdle(minIdle);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(20000);
            config.setValidationTimeout(5000);
            config.setMaxLifetime(60000); // 60 seconds keeps connections fresh for Supabase pooler
            config.setKeepaliveTime(25000); // 25s ping prevents pooler idle drops
            config.setPoolName("HostelEaseHikariPool");

            // PostgreSQL optimizations
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            logger.info("HikariCP initialized successfully connecting to PostgreSQL at {}:{}/{} (user: {}, sslmode: {})",
                    host, port, dbName, user, sslMode);

        } catch (Exception e) {
            logger.error("Failed to initialize HikariCP DataSource: {}", e.getMessage());
            throw new RuntimeException("Database connection pool initialization failed: " + e.getMessage(), e);
        }
    }

    private static String getVal(String primary, String fallback) {
        return (primary != null && !primary.trim().isEmpty()) ? primary.trim() : fallback;
    }

    /**
     * Obtains a connection from the pool.
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            initDataSource();
        }
        return dataSource.getConnection();
    }

    /**
     * Performs a comprehensive database health check.
     */
    public static boolean checkHealth() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT 1")) {
            return rs.next() && rs.getInt(1) == 1;
        } catch (Exception e) {
            logger.error("Database health check failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Gracefully shuts down connection pool on context destruction.
     */
    public static synchronized void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            logger.info("Closing HikariCP DataSource pool");
            dataSource.close();
        }
    }
}
