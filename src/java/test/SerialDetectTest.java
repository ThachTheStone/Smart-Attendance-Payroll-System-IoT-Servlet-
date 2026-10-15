/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

/**
 *
 * @author ngocthach
 */

import com.fazecast.jSerialComm.SerialPort;
import java.util.Scanner;

public class SerialDetectTest {

    public static void main(String[] args) {
        System.out.println("=== Scanning for Connected Serial Devices ===");
        
        SerialPort[] ports = SerialPort.getCommPorts();
        
        if (ports.length == 0) {
            System.err.println("No serial ports found! Check your USB cable and drivers.");
            return;
        }

        SerialPort espPort = null;

        for (int i = 0; i < ports.length; i++) {
            SerialPort p = ports[i];
            System.out.printf("[%d] %s - %s (Manufacturer: %s)\n", 
                i, 
                p.getSystemPortName(), 
                p.getDescriptivePortName(),
                p.getPortDescription()
            );

            // Auto-detect common USB-to-UART chips (CP210x, CH340, FTDI) or ESP32
            String desc = (p.getDescriptivePortName() + " " + p.getPortDescription()).toLowerCase();
            if (desc.contains("cp210") || desc.contains("ch340") || desc.contains("usb-serial") || desc.contains("uart")) {
                espPort = p;
            }
        }

        if (espPort == null) {
            // Default to the first available port if no exact keyword match
            espPort = ports[0];
            System.out.println("\nAuto-select default port: " + espPort.getSystemPortName());
        } else {
            System.out.println("\nDetected probable ESP32 on: " + espPort.getSystemPortName());
        }

        // --- Test Opening & Reading ---
        System.out.println("Attempting to connect at 115200 baud...");
        espPort.setBaudRate(115200);
        espPort.setComPortTimeouts(SerialPort.TIMEOUT_SCANNER, 0, 0);

        if (!espPort.openPort()) {
            System.err.println("FAILED to open port " + espPort.getSystemPortName() + ". (Check if Arduino Serial Monitor is open!)");
            return;
        }

        System.out.println("Port OPEN successfully! Reading incoming data for 10 seconds...");
        System.out.println("----------------------------------------------------------------");

        try (Scanner scanner = new Scanner(espPort.getInputStream())) {
            long startTime = System.currentTimeMillis();
            
            // Read incoming lines for 10 seconds
            while (System.currentTimeMillis() - startTime < 10000) {
                if (scanner.hasNextLine()) {
                    String line = scanner.nextLine();
                    System.out.println("[ESP32 Output]: " + line);
                }
            }
        } catch (Exception e) {
            System.err.println("Error reading from serial: " + e.getMessage());
        } finally {
            espPort.closePort();
            System.out.println("----------------------------------------------------------------");
            System.out.println("Test completed. Port closed.");
        }
    }
}
