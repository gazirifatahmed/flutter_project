package com.online.food.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Table
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MenuCategory {

    @Id
    @GeneratedValue(strategy= GenerationType.SEQUENCE)
    private int id;

    private String name;

    @ManyToOne
    @JoinColumn(name = "restaurants_id", referencedColumnName = "id")
    private Restaurants restaurants;

    private String description;


}