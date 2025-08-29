package com.online.food.util;

import com.itextpdf.io.source.ByteArrayOutputStream;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.UnitValue;
import com.online.food.model.Order;
import com.online.food.model.OrderItem;
import org.aspectj.weaver.ast.Or;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class PdfInvoiceBuilder {

    public byte[] build(Order data) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            PdfWriter writer = new PdfWriter(out);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            addHeader(document,data.getOrderItems().get(0).getMenuItem().getMenuCategory().getRestaurants().getRestaurantName());
            addCustomerDetails(document, data);
            addOrderItems(document, data);
            addSummary(document, data);
            addFooter(document);

            document.close();
            return out.toByteArray();
        } catch (Exception ex) {
            throw new RuntimeException("PDF generation failed", ex);
        }
    }

    private void addHeader(Document doc, String restaurantName) {
        doc.add(new Paragraph("🧾 " + restaurantName + " INVOICE").setBold().setFontSize(18));
        doc.add(new Paragraph("Powered by Online Food Platform").setFontSize(10));
    }


    private void addCustomerDetails(Document doc, Order data) {
        doc.add(new Paragraph("Customer: " + data.getUser().getUsername()));
        doc.add(new Paragraph("Address: " + "Dhaka"));
        doc.add(new Paragraph("Order Date: " + data.getOrderDate()));
    }

    private void addOrderItems(Document doc, Order data) {
        List<OrderItem> items = data.getOrderItems();
        Table table = new Table(UnitValue.createPercentArray(new float[]{40, 20, 20, 20})).useAllAvailableWidth();
        table.addHeaderCell("Item").addHeaderCell("Qty").addHeaderCell("Price").addHeaderCell("Total");

        for (OrderItem item : items) {
            table.addCell(item.getMenuItem().getName());
            table.addCell(String.valueOf(item.getQuantity()));
            table.addCell("Taka" + item.getMenuItem().getPrice());
            table.addCell("Taka" + data.getTotalAmount());
        }

        doc.add(table);
    }

    private void addSummary(Document doc, Order data) {
        doc.add(new Paragraph("Total: Taka" + data.getTotalAmount()));
        doc.add(new Paragraph("Tax ID: " + "#123456789"));
    }

    private void addFooter(Document doc) {
        doc.add(new Paragraph("Thank you for your purchase!"));
    }
}
