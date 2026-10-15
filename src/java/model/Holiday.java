package model;

import java.time.LocalDate;

public class Holiday {
    private LocalDate date;
    private String name;

    public Holiday() {
    }

    public Holiday(LocalDate date, String name) {
        this.date = date;
        this.name = name;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
