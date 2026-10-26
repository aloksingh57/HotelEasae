package com.hostelease.config;

import com.hostelease.dao.LeaveDAO;
import com.hostelease.notification.NotificationDispatcher;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger logger = LoggerFactory.getLogger(AppContextListener.class);
    private ScheduledExecutorService overdueReconciler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("Initializing HostelEase Web Application Context");

        // 1. Verify DB Connection
        boolean dbOk = DatabaseConfig.checkHealth();
        if (dbOk) {
            logger.info("Database connection established and verified successfully");
        } else {
            logger.error("WARNING: Initial database health check failed! Please verify PostgreSQL credentials and hostelease_db database status.");
        }

        // 2. Start Notification Dispatcher
        NotificationDispatcher.getInstance().start();

        // 3. Start Overdue Return Reconciliation Job (runs every 60 seconds)
        overdueReconciler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "HostelEase-OverdueReconciler");
            t.setDaemon(true);
            return t;
        });

        LeaveDAO leaveDAO = new LeaveDAO();
        overdueReconciler.scheduleWithFixedDelay(() -> {
            try {
                leaveDAO.reconcileOverdueLeaves();
            } catch (Exception e) {
                logger.error("Error running periodic overdue leave reconciliation: {}", e.getMessage());
            }
        }, 10, 60, TimeUnit.SECONDS);

        logger.info("HostelEase application started successfully.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("Shutting down HostelEase Web Application Context");

        if (overdueReconciler != null && !overdueReconciler.isShutdown()) {
            overdueReconciler.shutdown();
        }

        NotificationDispatcher.getInstance().stop();
        DatabaseConfig.shutdown();
        logger.info("HostelEase application shutdown complete.");
    }
}
