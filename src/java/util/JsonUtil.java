    /*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author ngocthach
 */
public class JsonUtil {
    
    //Reads the entire JSON payload sent in the HTTP request body
    public static String readyBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        try(BufferedReader reader = request.getReader()){
            String line;
            while ((line = reader.readLine()) != null){
                sb.append(line);
            }
        }
        return sb.toString().trim();
    }
    
    //EXTRACTS A STRING PREPERTY FROM A SIMPLE JSON {"status": "DONE"}
    public static String getString(String json, String key){
        if( json == null || key == null) return null;
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }
    
    /**
     * Extracts an Integer property: {"templateId": 12}
     * Returns null if key is missing or set to null: {"templateId": null}
     */
    public static Integer getInteger(String json, String key) {
        if (json == null || key == null) return null;
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(-?\\d+|null)");
        Matcher m = p.matcher(json);
        if (m.find()) {
            String val = m.group(1);
            if ("null".equals(val)) return null;
            try {
                return Integer.parseInt(val);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
    
     /**
     * Sends a JSON response with status code and UTF-8 encoding.
     */
    public static void sendJson(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }
    
    /**
     * Helper to build a standard error JSON response: {"error": "..."}
     */
    public static String error(String message) {
        return "{\"error\":\"" + escape(message) + "\"}";
    }
    
     /**
     * Helper to build a standard success JSON response: {"ok": true}
     */
    public static String success() {
        return "{\"ok\":true}";
    }
    
    public static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
