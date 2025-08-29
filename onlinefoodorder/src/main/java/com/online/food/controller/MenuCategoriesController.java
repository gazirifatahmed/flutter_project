package com.online.food.controller;

import com.online.food.dto.MenuCategoryDto;
import com.online.food.model.MenuCategory;
import com.online.food.service.MenuCategoriesService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")

@RequiredArgsConstructor
public class MenuCategoriesController {

    private final MenuCategoriesService menuCategoriesService;


    @PostMapping("")
    public MenuCategory save(@RequestBody MenuCategory menuCategory) {
        return menuCategoriesService.save(menuCategory);
    }

    @GetMapping
    public List<MenuCategory> getAllMenuCategories() {
        return menuCategoriesService.findAll();
    }

    @PutMapping("/{id}")
    public MenuCategory update(@RequestBody MenuCategory menuCategory, @PathVariable int id) {
        return menuCategoriesService.update(id,menuCategory);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable int id) {
        menuCategoriesService.deleteById(id);
    }

}
