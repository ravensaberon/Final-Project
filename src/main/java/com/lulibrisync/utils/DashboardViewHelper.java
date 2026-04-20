package com.lulibrisync.utils;

import java.util.List;
import java.util.Locale;
import java.util.Map;

public final class DashboardViewHelper {

    private DashboardViewHelper() {
    }

    public static String escapeHtml(Object value) {
        String text = value == null ? "" : String.valueOf(value);
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public static String dashArray(int percent) {
        double circumference = 452.39d;
        double dash = Math.max(0d, Math.min(100d, percent)) * circumference / 100d;
        return String.format(Locale.US, "%.2f 999", dash);
    }

    public static int toInt(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    public static int maxValue(List<Map<String, Object>> rows) {
        int max = 0;
        if (rows == null) {
            return max;
        }
        for (Map<String, Object> row : rows) {
            max = Math.max(max, toInt(row.get("value")));
        }
        return max;
    }

    public static int percentOf(int value, int total) {
        if (total <= 0) {
            return 0;
        }
        return (int) Math.round((value * 100.0d) / total);
    }

    public static double chartX(int index, int count, int width, int padX) {
        if (count <= 1) {
            return width / 2.0d;
        }
        double usableWidth = width - (padX * 2.0d);
        return padX + ((usableWidth * index) / (count - 1.0d));
    }

    public static double chartY(int value, int max, int height, int padTop, int padBottom) {
        double usableHeight = height - padTop - padBottom;
        if (max <= 0) {
            return height - padBottom;
        }
        return padTop + usableHeight - ((value * usableHeight) / max);
    }

    public static String fmt(double value) {
        return String.format(Locale.US, "%.2f", value);
    }

    public static String linePoints(List<Map<String, Object>> rows, int width, int height, int padX, int padTop,
            int padBottom) {
        if (rows == null || rows.isEmpty()) {
            return "";
        }

        int max = Math.max(1, maxValue(rows));
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) {
                builder.append(' ');
            }
            int value = toInt(rows.get(i).get("value"));
            builder.append(fmt(chartX(i, rows.size(), width, padX)))
                    .append(',')
                    .append(fmt(chartY(value, max, height, padTop, padBottom)));
        }
        return builder.toString();
    }

    public static String areaPoints(List<Map<String, Object>> rows, int width, int height, int padX, int padTop,
            int padBottom) {
        if (rows == null || rows.isEmpty()) {
            return "";
        }

        double baseline = height - padBottom;
        StringBuilder builder = new StringBuilder();
        builder.append(fmt(chartX(0, rows.size(), width, padX)))
                .append(',')
                .append(fmt(baseline))
                .append(' ')
                .append(linePoints(rows, width, height, padX, padTop, padBottom))
                .append(' ')
                .append(fmt(chartX(rows.size() - 1, rows.size(), width, padX)))
                .append(',')
                .append(fmt(baseline));
        return builder.toString();
    }
}
