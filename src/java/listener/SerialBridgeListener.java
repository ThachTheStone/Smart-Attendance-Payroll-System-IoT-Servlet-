/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package listener;

/**
 *
 * @author ngocthach
 */

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import util.SerialBridge;

@WebListener
public class SerialBridgeListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        SerialBridge.startAsync();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        SerialBridge.stopBridge();
    }
}

