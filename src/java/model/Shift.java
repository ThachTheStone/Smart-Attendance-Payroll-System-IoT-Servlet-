package model;

import java.time.LocalTime;

public class Shift {
    private int id;
    private String name;
    private LocalTime startTime;
    private LocalTime endTime;
    private int breakMinutes;

    public Shift() {
    }

    public Shift(int id, String name, LocalTime startTime, LocalTime endTime, int breakMinutes) {
        this.id = id;
        this.name = name;
        this.startTime = startTime;
        this.endTime = endTime;
        this.breakMinutes = breakMinutes;
    }

    public Shift(String name, LocalTime startTime, LocalTime endTime, int breakMinutes) {
        this.name = name;
        this.startTime = startTime;
        this.endTime = endTime;
        this.breakMinutes = breakMinutes;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public int getBreakMinutes() {
        return breakMinutes;
    }

    public void setBreakMinutes(int breakMinutes) {
        this.breakMinutes = breakMinutes;
    }

    public String getFormattedStartTime() {
        if (startTime == null) return "06:00";
        String s = startTime.toString();
        return s.length() >= 5 ? s.substring(0, 5) : s;
    }

    public String getFormattedEndTime() {
        if (endTime == null) return "14:00";
        String s = endTime.toString();
        return s.length() >= 5 ? s.substring(0, 5) : s;
    }

    /**
     * Checks if this is a night shift that crosses midnight (e.g. 22:00 to 06:00).
     */
    public boolean isOvernight() {
        if (startTime == null || endTime == null) return false;
        return endTime.isBefore(startTime);
    }

    public int getDurationMinutes() {
        if (startTime == null || endTime == null) return 480;
        if (isOvernight()) {
            int untilMidnight = 24 * 60 - (startTime.getHour() * 60 + startTime.getMinute());
            int afterMidnight = endTime.getHour() * 60 + endTime.getMinute();
            return Math.max(0, (untilMidnight + afterMidnight) - breakMinutes);
        } else {
            int diff = (endTime.getHour() * 60 + endTime.getMinute()) - (startTime.getHour() * 60 + startTime.getMinute());
            return Math.max(0, diff - breakMinutes);
        }
    }
}
