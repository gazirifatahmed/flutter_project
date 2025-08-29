package com.online.food.service;


import com.online.food.dto.MenuCategoryDto;
import com.online.food.model.MenuCategory;
import com.online.food.model.Restaurants;
import com.online.food.repository.MenuCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MenuCategoriesService {

    private final MenuCategoryRepository menuCategoryRepository;
    private final RestaurantsService restaurantsService;

    public MenuCategory save(MenuCategory menuCategory) {

        Restaurants restaurants = restaurantsService.findById(menuCategory.getRestaurants().getId());
        if (restaurants == null) {
            throw new RuntimeException("Restaurants not found");
        }

        menuCategory.setName(menuCategory.getName());
        menuCategory.setRestaurants(restaurants);
        menuCategory.setDescription(menuCategory.getDescription());
        return menuCategoryRepository.save(menuCategory);
    }

    public List<MenuCategory> findAll() {
        return menuCategoryRepository.findAll();
    }

    public void deleteById(int id) {
        menuCategoryRepository.deleteById(id);
    }

    public MenuCategory update(int id, MenuCategory menuCategory) {
        MenuCategory menuCategoryExists = menuCategoryRepository.findById(id).orElse(null);
        if (menuCategoryExists == null) {
            throw new RuntimeException("MenuCategory not found");
        }
        Restaurants restaurants = restaurantsService.findById(menuCategory.getRestaurants().getId());
        if (restaurants == null) {
            throw new RuntimeException("Restaurants not found");
        }
        menuCategoryExists.setName(menuCategory.getName());
        menuCategoryExists.setRestaurants(restaurants);
        menuCategoryExists.setDescription(menuCategory.getDescription());
        return menuCategoryRepository.save(menuCategoryExists);
    }

    public MenuCategory findById(int menuCategoryId) {
        return menuCategoryRepository.findById(menuCategoryId).orElse(null);
    }
}
