package com.hostelease.servlet;

import com.hostelease.util.DatabaseConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Diagnostic Endpoint for Supabase PostgreSQL Connectivity.
 * URL: /api/diagnostics/db
 * 
 * Executes safe read tests (SELECT 1, record counts) without exposing credentials.
 */
@WebServlet(name = "SupabaseDiagnosticServlet", urlPatterns = {"/api/diagnostics/db"})
public class SupabaseDiagnosticServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        DatabaseConnection.DiagnosticResult result = DatabaseConnection.testConnection();

        if (result.success) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        try (PrintWriter out = response.getWriter()) {
            out.print("{\n");
            out.printf("  \"status\": \"%s\",\n", result.success ? "HEALTHY" : "UNHEALTHY");
            out.printf("  \"backend\": \"Supabase PostgreSQL\",\n");
            out.printf("  \"message\": \"%s\",\n", escapeJson(result.message));
            out.printf("  \"host\": \"%s\",\n", escapeJson(result.host));
            out.printf("  \"port\": \"%s\",\n", escapeJson(result.port));
            out.printf("  \"database\": \"%s\",\n", escapeJson(result.database));
            out.printf("  \"connectedUser\": \"%s\",\n", escapeJson(result.user));
            out.printf("  \"sslMode\": \"%s\",\n", escapeJson(result.sslMode));
            out.printf("  \"latencyMs\": %d,\n", result.latencyMs);
            out.printf("  \"selectOneCheck\": %b,\n", result.selectOneOk);
            out.printf("  \"activeUsersCount\": %d,\n", result.userCount);
            out.printf("  \"activeHostelsCount\": %d\n", result.hostelCount);
            out.print("}\n");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
