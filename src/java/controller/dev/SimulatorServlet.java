/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.dev;

/**
 *
 * @author ngocthach
 */
import dal.DeviceDAO;
import dal.FingerprintDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Account;
import model.Device;
import model.Fingerprint;
import model.Role;
import util.Constants;

@WebServlet(name = "SimulatorServlet", urlPatterns = {"/dev/simulator", "/admin/simulator"})
public class SimulatorServlet extends HttpServlet {

    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final FingerprintDAO fingerprintDAO = new FingerprintDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Only ADMIN is allowed to access device simulator
        HttpSession session = request.getSession(false);
        Account user = session == null ? null : (Account) session.getAttribute(Constants.SESSION_USER);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRole() != Role.ADMIN) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.getRequestDispatcher("/WEB-INF/views/common/403.jsp").forward(request, response);
            return;
        }

        // 2. Load devices and enrolled fingerprints
        List<Device> devices = deviceDAO.findAll();
        List<Fingerprint> fingerprints = fingerprintDAO.findAll();

        request.setAttribute("devices", devices);
        request.setAttribute("fingerprints", fingerprints);

        request.getRequestDispatcher("/WEB-INF/views/dev/simulator.jsp").forward(request, response);
    }
}
