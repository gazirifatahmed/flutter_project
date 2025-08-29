package com.online.food.service;

import com.online.food.dto.MenuItemDto;
import com.online.food.model.MenuCategory;
import com.online.food.model.MenuItem;
import com.online.food.repository.MenuItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MenuItemService {

    private final MenuItemRepository menuItemRepository;
    private final MenuCategoriesService menuCategoriesService;

    public MenuItem save(MenuItemDto menuItemDto) {

        MenuCategory menuCategory = menuCategoriesService.findById(menuItemDto.getMenuCategoryId());
        if (menuCategory == null) {
            throw new RuntimeException("MenuCategory not found");
        }
        MenuItem menuItem = new MenuItem();
        menuItem.setName(menuItemDto.getName());
        menuItem.setPrice(menuItemDto.getPrice());
        menuItem.setDescription(menuItemDto.getDescription());
        menuItem.setMenuCategory(menuCategory);
        menuItem.setImage(menuItemDto.getImage());
        return menuItemRepository.save(menuItem);
    }


    public List<MenuItem> findAll() {
        return menuItemRepository.findAll();
    }

    public MenuItem update(int id, MenuItemDto menuItemDto) {
        MenuItem menuItem = menuItemRepository.findById(id).orElse(null);
        if (menuItem == null) {
            throw new RuntimeException("MenuItem not found");
        }

        MenuCategory menuCategory = menuCategoriesService.findById(menuItemDto.getMenuCategoryId());
        if (menuCategory == null) {
            throw new RuntimeException("MenuCategory not found");
        }
        menuItem.setMenuCategory(menuCategory);

        menuItem.setName(menuItemDto.getName());
        menuItem.setPrice(menuItemDto.getPrice());
        menuItem.setDescription(menuItemDto.getDescription());
        menuItem.setImage(menuItemDto.getImage());
        return menuItemRepository.save(menuItem);
    }

    public void deleteById(int id) {
        menuItemRepository.deleteById(id);
    }
}
