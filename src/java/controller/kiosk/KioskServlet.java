package controller.kiosk;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Man hinh kiosk tren laptop (FR-KIOSK-01, 02, 07). Sprint nay: trang cho (dong ho + loi nhac).
 * TODO sprint sau: nhan su kien quet van tay qua SSE /kiosk/stream.
 */
@WebServlet(name = "KioskServlet", urlPatterns = {"/kiosk"})
public class KioskServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/kiosk/index.jsp").forward(req, res);
    }
}
