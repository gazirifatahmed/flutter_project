package com.online.food.config;

import com.online.food.model.MenuCategory;
import com.online.food.model.MenuItem;
import com.online.food.model.Restaurants;
import com.online.food.repository.MenuCategoryRepository;
import com.online.food.repository.MenuItemRepository;
import com.online.food.repository.RestaurantsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;


@Component
@RequiredArgsConstructor
public class DataLoader implements ApplicationRunner {

    private final RestaurantsRepository restaurantsRepository;
    private final MenuCategoryRepository menuCategoryRepository;
    private final MenuItemRepository menuItemRepository;


    @Override
    public void run(ApplicationArguments args) throws Exception {

        Restaurants restaurants = Restaurants.builder()
                .restaurantName("KFC")
                .email("r0BtM@example.com")
                .phoneNumber("1234567890")
                .restaurantAddress("123 Main St")
                .build();

        if (restaurantsRepository.count() == 0) {
            restaurants = restaurantsRepository.save(restaurants); // ✅ saved reference
        } else {
            // Just get an existing one (assuming only one for now)
            restaurants = restaurantsRepository.findAll().get(0); // or use `findByRestaurantName("KFC")` if applicable
        }

        MenuCategory menuCategory = MenuCategory.builder()
                .name("Burger")
                .description("Burger")
                .restaurants(restaurants)
                .build();

        if (menuCategoryRepository.count() == 0) {
            menuCategory = menuCategoryRepository.save(menuCategory); // ✅ save after attaching saved restaurant
        } else {
            menuCategory = menuCategoryRepository.findAll().get(0);
        }

        MenuItem menuItem = MenuItem.builder()
                .name("Burger")
                .description("Burger")
                .price(100.0)
                .menuCategory(menuCategory)
                .build();

        if (menuItemRepository.count() == 0) {
            menuItemRepository.save(menuItem);
        }
    }
}