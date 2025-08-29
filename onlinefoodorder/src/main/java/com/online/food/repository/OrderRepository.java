package com.online.food.repository;

import com.online.food.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Integer> {

    @Query("SELECT o FROM Order o WHERE o.user.id = :userId")
    List<Order> findByUserId(@Param("userId") int userId);

    // ✅ নতুন Delivered + Unread অর্ডার
    List<Order> findByOrderStatusAndReadByAdmin(String status, boolean readByAdmin);
}
