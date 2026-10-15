package listener;

import dal.AttendanceDAO;
import dal.DeviceDAO;
import java.time.LocalDate;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class SchedulerListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(SchedulerListener.class.getName());

    private ScheduledExecutorService scheduler;
    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("[SchedulerListener] Starting background attendance & device monitor...");

        scheduler = Executors.newScheduledThreadPool(2);

        // Job 1: Check and mark MISSING_CHECKOUT every 5 minutes (FR-ATT-04)
        scheduler.scheduleAtFixedRate(() -> {
            try {
                int updated = attendanceDAO.markMissingCheckouts();
                if (updated > 0) {
                    LOGGER.info("[Scheduler] Marked " + updated + " attendance record(s) as MISSING_CHECKOUT (>2h after shift end).");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "[Scheduler] Error running markMissingCheckouts", e);
            }
        }, 1, 5, TimeUnit.MINUTES);

        // Job 2: Check and mark ABSENT for unattended shifts once per hour
        scheduler.scheduleAtFixedRate(() -> {
            try {
                LocalDate yesterday = LocalDate.now().minusDays(1);
                int absents = attendanceDAO.markAbsentForUnattendedShifts(yesterday);
                if (absents > 0) {
                    LOGGER.info("[Scheduler] Generated " + absents + " ABSENT record(s) for date " + yesterday);
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "[Scheduler] Error running markAbsentForUnattendedShifts", e);
            }
        }, 2, 60, TimeUnit.MINUTES);

        // Job 3: Monitor device health every 30 seconds
        scheduler.scheduleAtFixedRate(() -> {
            try {
                java.util.List<model.Device> devices = deviceDAO.findAll();
                for (model.Device d : devices) {
                    realtime.SseHub.getInstance().broadcastDeviceStatus(d.getId(), d.getName(), d.isOnline());
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "[Scheduler] Error during device health check", e);
            }
        }, 15, 30, TimeUnit.SECONDS);

        LOGGER.info("[SchedulerListener] Background tasks scheduled successfully.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("[SchedulerListener] Shutting down background scheduler...");
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        LOGGER.info("[SchedulerListener] Background scheduler stopped.");
    }
}
