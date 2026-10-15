package service;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import model.PayrollDetail;

/**
 * Service for generating professional PDF payslips using OpenPDF (FR-PAY-05).
 * Supports individual payslips and multi-page batch company export.
 */
public class PayslipPdfService {

    private final NumberFormat currencyFormat = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    private static BaseFont unicodeBaseFont = null;

    static {
        try {
            File fontFile = new File("C:/Windows/Fonts/arial.ttf");
            if (fontFile.exists()) {
                unicodeBaseFont = BaseFont.createFont(fontFile.getAbsolutePath(), BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            }
        } catch (Exception e) {
            unicodeBaseFont = null;
        }
    }

    private Font getFont(float size, int style, Color color) {
        if (unicodeBaseFont != null) {
            return new Font(unicodeBaseFont, size, style, color);
        }
        return FontFactory.getFont(FontFactory.HELVETICA, size, style, color);
    }

    /**
     * Generates a PDF payslip for a single employee and returns byte array.
     */
    public byte[] generatePayslipPdf(PayrollDetail detail, int month, int year) throws DocumentException, IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        generatePayslipPdf(detail, month, year, baos);
        return baos.toByteArray();
    }

    /**
     * Streams the generated PDF payslip directly to an OutputStream.
     */
    public void generatePayslipPdf(PayrollDetail d, int month, int year, OutputStream out) throws DocumentException {
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(document, out);
        document.open();
        addPayslipContent(document, d, month, year);
        document.close();
    }

    /**
     * Generates a multi-page PDF containing payslips for all employees in a batch.
     */
    public void generateBatchPayslipsPdf(List<PayrollDetail> details, int month, int year, OutputStream out) throws DocumentException {
        if (details == null || details.isEmpty()) {
            throw new IllegalArgumentException("Khong co du lieu nhan su trong bang luong");
        }
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(document, out);
        document.open();

        for (int i = 0; i < details.size(); i++) {
            PayrollDetail d = details.get(i);
            addPayslipContent(document, d, month, year);
            if (i < details.size() - 1) {
                document.newPage();
            }
        }

        document.close();
    }

    /**
     * Generates a multi-page PDF batch as byte array.
     */
    public byte[] generateBatchPayslipsPdf(List<PayrollDetail> details, int month, int year) throws DocumentException, IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        generateBatchPayslipsPdf(details, month, year, baos);
        return baos.toByteArray();
    }

    /**
     * Appends a complete payslip page to the document.
     */
    private void addPayslipContent(Document document, PayrollDetail d, int month, int year) throws DocumentException {
        Font titleFont = getFont(18, Font.BOLD, Color.BLACK);
        Font subTitleFont = getFont(11, Font.NORMAL, new Color(71, 85, 105));
        Font headerFont = getFont(10, Font.BOLD, Color.WHITE);
        Font boldFont = getFont(10, Font.BOLD, Color.BLACK);
        Font normalFont = getFont(10, Font.NORMAL, new Color(30, 41, 59));
        Font totalFont = getFont(12, Font.BOLD, new Color(5, 150, 105));
        Font companyFont = getFont(11, Font.BOLD, new Color(37, 99, 235));

        // Company header
        Paragraph comp = new Paragraph("CÔNG TY CP SMARTATTEND VIỆT NAM", companyFont);
        comp.setAlignment(Element.ALIGN_LEFT);
        document.add(comp);

        Paragraph addr = new Paragraph("Hệ thống Chấm công Sinh trắc học & Tính lương Tự động SmartAttend", subTitleFont);
        addr.setSpacingAfter(15);
        document.add(addr);

        // Payslip Title
        Paragraph title = new Paragraph("PHIẾU LƯƠNG NHÂN VIÊN / PAYSLIP", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);

        Paragraph period = new Paragraph("Kỳ lương: Tháng " + String.format("%02d", month) + " / " + year, subTitleFont);
        period.setAlignment(Element.ALIGN_CENTER);
        period.setSpacingAfter(18);
        document.add(period);

        // Employee Info Table
        PdfPTable infoTable = new PdfPTable(4);
        infoTable.setWidthPercentage(100);
        infoTable.setSpacingAfter(18);
        infoTable.setWidths(new float[]{22, 28, 22, 28});

        addInfoCell(infoTable, "Mã nhân viên:", d.getEmployeeCode(), boldFont, normalFont);
        addInfoCell(infoTable, "Họ và tên:", d.getEmployeeName(), boldFont, normalFont);
        addInfoCell(infoTable, "Phòng ban:", d.getDepartment(), boldFont, normalFont);
        addInfoCell(infoTable, "Chức vụ:", d.getPosition(), boldFont, normalFont);
        addInfoCell(infoTable, "Loại lương:", d.getSalaryType(), boldFont, normalFont);
        addInfoCell(infoTable, "Lương cơ bản:", fmt(d.getBaseSalary()) + " VND", boldFont, normalFont);
        addInfoCell(infoTable, "Lương 1 giờ (Rate):", fmt(d.getHourlyRate()) + " VND/h", boldFont, normalFont);
        addInfoCell(infoTable, "Tổng giờ OT:", d.getTotalOvertimeHours() + " giờ", boldFont, normalFont);

        document.add(infoTable);

        // Earnings & Deductions Breakdown Table
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{42, 20, 15, 23});
        table.setSpacingAfter(22);

        Color headerColor = new Color(30, 41, 59);
        addHeaderCell(table, "Khoản mục thu nhập / Khấu trừ", headerFont, headerColor);
        addHeaderCell(table, "Chi tiết giờ / phút", headerFont, headerColor);
        addHeaderCell(table, "Hệ số", headerFont, headerColor);
        addHeaderCell(table, "Thành tiền (VND)", headerFont, headerColor);

        // 1. Regular hours
        addRow(table, "1. Lương giờ tiêu chuẩn (Regular Pay)", d.getRegularHours() + " giờ", "100%", fmt(d.getRegularPay()), normalFont);

        // 2. OT Weekday (150%)
        addRow(table, "2. Làm thêm ngày thường (Weekday OT)", d.getOtWeekdayHours() + " giờ", "150%", fmt(d.getOtWeekdayPay()), normalFont);

        // 3. OT Weekend (200%)
        addRow(table, "3. Làm thêm ngày nghỉ cuối tuần (Weekend OT)", d.getOtWeekendHours() + " giờ", "200%", fmt(d.getOtWeekendPay()), normalFont);

        // 4. OT Holiday (300%)
        addRow(table, "4. Làm thêm ngày lễ/Tết (Holiday OT)", d.getOtHolidayHours() + " giờ", "300%", fmt(d.getOtHolidayPay()), normalFont);

        // 5. Night Allowance (30%)
        addRow(table, "5. Phụ cấp làm việc ban đêm (22h - 06h)", d.getNightHours() + " giờ", "+30%", fmt(d.getNightAllowance()), normalFont);

        // 6. Night OT Bonus (20%)
        addRow(table, "6. Thưởng làm thêm ca đêm", d.getNightOtHours() + " giờ", "+20%", fmt(d.getNightOtBonus()), normalFont);

        // 7. Late Penalty
        addRow(table, "7. Khấu trừ phạt đi muộn (sau ân hạn)", d.getLateMinutes() + " phút", "-1,000 đ/m", "-" + fmt(d.getPenalty()), normalFont);

        // Total Net Row
        PdfPCell totalLabelCell = new PdfPCell(new Phrase("TỔNG LƯƠNG THỰC NHẬN (NET SALARY):", totalFont));
        totalLabelCell.setColspan(3);
        totalLabelCell.setPadding(8);
        totalLabelCell.setBackgroundColor(new Color(236, 253, 245));
        totalLabelCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(totalLabelCell);

        PdfPCell totalValCell = new PdfPCell(new Phrase(fmt(d.getNetSalary()) + " VND", totalFont));
        totalValCell.setPadding(8);
        totalValCell.setBackgroundColor(new Color(236, 253, 245));
        totalValCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(totalValCell);

        document.add(table);

        // Signatures Block
        PdfPTable signTable = new PdfPTable(3);
        signTable.setWidthPercentage(100);
        signTable.setSpacingBefore(16);

        addSignCell(signTable, "Người lập phiếu", "(Ký, họ tên)", normalFont, boldFont);
        addSignCell(signTable, "Kế toán trưởng", "(Ký, họ tên)", normalFont, boldFont);
        addSignCell(signTable, "Người nhận lương", "(Ký, họ tên)", normalFont, boldFont);

        document.add(signTable);
    }

    private void addInfoCell(PdfPTable table, String label, String val, Font bold, Font norm) {
        PdfPCell cell = new PdfPCell();
        cell.setBorder(0);
        cell.setPadding(4);
        cell.addElement(new Phrase(label + " ", bold));
        cell.addElement(new Phrase(val != null ? val : "--", norm));
        table.addCell(cell);
    }

    private void addHeaderCell(PdfPTable table, String text, Font font, Color bg) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(bg);
        cell.setPadding(8);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(cell);
    }

    private void addRow(PdfPTable table, String desc, String qty, String rate, String amount, Font font) {
        PdfPCell c1 = new PdfPCell(new Phrase(desc, font));
        c1.setPadding(6);
        table.addCell(c1);

        PdfPCell c2 = new PdfPCell(new Phrase(qty, font));
        c2.setPadding(6);
        c2.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(c2);

        PdfPCell c3 = new PdfPCell(new Phrase(rate, font));
        c3.setPadding(6);
        c3.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(c3);

        PdfPCell c4 = new PdfPCell(new Phrase(amount, font));
        c4.setPadding(6);
        c4.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(c4);
    }

    private void addSignCell(PdfPTable table, String title, String sub, Font norm, Font bold) {
        PdfPCell cell = new PdfPCell();
        cell.setBorder(0);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        Paragraph p1 = new Paragraph(title, bold);
        p1.setAlignment(Element.ALIGN_CENTER);
        cell.addElement(p1);

        Paragraph p2 = new Paragraph(sub, norm);
        p2.setAlignment(Element.ALIGN_CENTER);
        p2.setSpacingAfter(40);
        cell.addElement(p2);

        table.addCell(cell);
    }

    private String fmt(Number n) {
        if (n == null) return "0";
        return currencyFormat.format(n);
    }
}
