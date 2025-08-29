package com.online.food.dto;

import lombok.Data;

@Data
public class MenuItemDto {
    private int id;
    private String name;
    private int menuCategoryId;
    private String description;
    private double price;
    private String image;

}
