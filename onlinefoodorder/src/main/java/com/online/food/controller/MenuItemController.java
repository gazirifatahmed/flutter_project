package com.online.food.controller;


import com.online.food.dto.MenuItemDto;
import com.online.food.model.MenuItem;
import com.online.food.service.MenuItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/menuItems")

@RequiredArgsConstructor
public class MenuItemController {

    private final MenuItemService menuItemService;

    @PostMapping("")
    public MenuItem save(@RequestBody MenuItemDto menuItemDto) {
        return menuItemService.save(menuItemDto);
    }

    @GetMapping("")
    public List<MenuItem> findAll() {
        return menuItemService.findAll();
    }

    @PutMapping("/{id}")
    public MenuItem update(@RequestBody MenuItemDto menuItemDto, @PathVariable int id) {
        return menuItemService.update(id,menuItemDto);
    }
    @DeleteMapping("/{id}")
    public void delete(@PathVariable int id) {
        menuItemService.deleteById(id);
    }
}
