package com.online.food.dto;


import lombok.Data;

@Data
public class MenuCategoryDto {

    private int id;
    private String name;
    private int restaurantsId;
    private String description;

}
