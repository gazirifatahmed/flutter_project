package com.online.food.service;

import com.online.food.model.Order;
import com.online.food.model.OrderItem;
import com.online.food.repository.OrderItemRepository;
import com.online.food.repository.OrderRepository;
import com.online.food.util.PdfInvoiceBuilder;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PdfInvoiceBuilder pdfBuilder;

    public Order saveOrder(Order order) {
        order.setOrderDate(LocalDateTime.now());
        order.setOrderStatus("PENDING");
        Order savedOrder = orderRepository.save(order);

        for (OrderItem item : order.getOrderItems()) {
            item.setOrder(savedOrder);
        }
        orderItemRepository.saveAll(order.getOrderItems());
        return savedOrder;
    }

    public List<Order> findAll() {
        return orderRepository.findAll();
    }

    public Order approveOrder(int id, String status) {
        Order order = orderRepository.findById(id).orElse(null);
        if (order == null) throw new RuntimeException("Order not found");
        order.setOrderStatus(Objects.requireNonNullElse(status, "APPROVED"));
        return orderRepository.save(order);
    }

    public Order updateStatus(int id, String status) {
        Order order = orderRepository.findById(id).orElseThrow(() -> new RuntimeException("Order not found"));
        order.setOrderStatus(status);
        return orderRepository.save(order);
    }

    public byte[] generateInvoice(int orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow(() -> new RuntimeException("Order not found"));
        return pdfBuilder.build(order);
    }

    public List<Order> findByUserId(int userId) {
        return orderRepository.findByUserId(userId);
    }

    // ✅ কাস্টমার ডেলিভারি কনফার্ম + রেটিং দিলে
    public Order updateRating(int id, double rating) {
        Order order = orderRepository.findById(id).orElse(null);
        if (order == null) throw new RuntimeException("Order not found");
        order.setOrderStatus("DELIVERED");
        order.setRating(rating);
        order.setReadByAdmin(false); // অ্যাডমিন এখনো দেখেনি
        return orderRepository.save(order);
    }

    // ✅ অ্যাডমিনের জন্য নতুন Delivered অর্ডার লিস্ট
    public List<Order> findNewDeliveredOrdersForAdmin() {
        return orderRepository.findByOrderStatusAndReadByAdmin("DELIVERED", false);
    }

    // ✅ অ্যাডমিন দেখেছে মার্ক করা
    public void markAllDeliveredOrdersAsSeen() {
        List<Order> orders = orderRepository.findByOrderStatusAndReadByAdmin("DELIVERED", false);
        for (Order order : orders) {
            order.setReadByAdmin(true);
        }
        orderRepository.saveAll(orders);
    }
}
