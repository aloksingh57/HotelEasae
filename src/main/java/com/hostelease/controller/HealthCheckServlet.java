package com.hostelease.controller;

import com.google.gson.JsonObject;
import com.hostelease.config.DatabaseConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet(name = "HealthCheckServlet", urlPatterns = {"/health"})
public class HealthCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        JsonObject json = new JsonObject();

        boolean reachable = false;
        boolean selectOk = false;
        int tablesFound = 0;
        String dbVersion = "Unknown";

        try (Connection conn = DatabaseConfig.getConnection()) {
            reachable = true;
            DatabaseMetaData meta = conn.getMetaData();
            dbVersion = meta.getDatabaseProductVersion();

            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT 1")) {
                if (rs.next() && rs.getInt(1) == 1) {
                    selectOk = true;
                }
            }

            try (ResultSet rs = meta.getTables(null, "public", "%", new String[]{"TABLE"})) {
                while (rs.next()) {
                    tablesFound++;
                }
            }
        } catch (Exception e) {
            json.addProperty("error", "Database connection failed: " + e.getMessage());
        }

        boolean healthy = reachable && selectOk && tablesFound >= 25;

        json.addProperty("status", healthy ? "HEALTHY" : "DEGRADED");
        json.addProperty("database_reachable", reachable);
        json.addProperty("query_execution", selectOk);
        json.addProperty("tables_detected", tablesFound);
        json.addProperty("database_version", dbVersion);
        json.addProperty("timestamp", System.currentTimeMillis());

        if (healthy) {
            resp.setStatus(HttpServletResponse.SC_OK);
        } else {
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        resp.getWriter().write(json.toString());
    }
}
