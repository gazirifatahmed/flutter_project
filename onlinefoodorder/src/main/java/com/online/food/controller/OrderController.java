package com.online.food.controller;

import com.online.food.model.Order;
import com.online.food.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    public Order saveOrder(@RequestBody Order order) {
        return orderService.saveOrder(order);
    }

    @PostMapping("/confirm")
    public Order confirmOrder(@RequestBody Order order) {
        return orderService.saveOrder(order);
    }

    @GetMapping
    public List<Order> findAll() {
        return orderService.findAll();
    }

    @PatchMapping("{id}")
    public Order updateOrder(@PathVariable int id,
                             @RequestHeader(value = "status", required = false) String status) {
        return orderService.approveOrder(id, status);
    }

    @PatchMapping("/{id}/status")
    public Order updateStatus(@PathVariable int id, @RequestBody Order orderReq) {
        return orderService.updateStatus(id, orderReq.getOrderStatus());
    }

    @RequestMapping(value = "/invoice/{id}", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<byte[]> downloadInvoice(@PathVariable int id) {
        byte[] invoiceData = orderService.generateInvoice(id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=invoice_" + id + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(invoiceData);
    }

    @GetMapping("/user/{userId}")
    public List<Order> findByUserId(@PathVariable int userId) {
        return orderService.findByUserId(userId);
    }

    @PatchMapping("/rating/{id}/{rating}")
    public Order updateRating(@PathVariable int id, @PathVariable double rating) {
        return orderService.updateRating(id, rating);
    }

    @PostMapping("/rating")
    public Order submitRating(@RequestBody RatingRequest ratingRequest) {
        return orderService.updateRating(ratingRequest.getOrderId(), ratingRequest.getRating());
    }

    // ✅ অ্যাডমিনের জন্য নতুন Delivered নোটিফিকেশন API
    @GetMapping("/admin-new-deliveries")
    public List<Order> getNewDeliveredOrdersForAdmin() {
        return orderService.findNewDeliveredOrdersForAdmin();
    }

    // ✅ অ্যাডমিন দেখেছে মার্ক করা API
    @PatchMapping("/admin-mark-seen")
    public void markDeliveredOrdersAsSeen() {
        orderService.markAllDeliveredOrdersAsSeen();
    }

    public static class RatingRequest {
        private int orderId;
        private double rating;
        public int getOrderId() { return orderId; }
        public void setOrderId(int orderId) { this.orderId = orderId; }
        public double getRating() { return rating; }
        public void setRating(double rating) { this.rating = rating; }
    }
}
