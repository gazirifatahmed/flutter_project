package com.online.food.controller;

import com.online.food.model.Restaurants;
import com.online.food.service.RestaurantsService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/restaurants")
public class RestaurantsController {

    private final RestaurantsService restaurantsService;

    public RestaurantsController(RestaurantsService restaurantsService) {
        this.restaurantsService = restaurantsService;
    }
    @GetMapping("")
    public List<Restaurants>  getAllRestaurants() {
        return restaurantsService.findAll();
    }
    @PostMapping("")
    public Restaurants save(@RequestBody Restaurants restaurants) {
        return restaurantsService.save(restaurants);
    }
    @GetMapping("/{id}")
    public Restaurants getRestaurantById(@PathVariable int id) {
        return restaurantsService.findById(id);
    }
    @PutMapping("/{id}")
    public Restaurants updateRestaurantById(@PathVariable int id, @RequestBody Restaurants restaurants) {
        Restaurants restaurants1 = restaurantsService.findById(id);
        restaurants1.setRestaurantName(restaurants.getRestaurantName());
        restaurants1.setEmail(restaurants.getEmail());
        restaurants1.setPhoneNumber(restaurants.getPhoneNumber());
        restaurants1.setRestaurantAddress(restaurants.getRestaurantAddress());
        return restaurantsService.update(restaurants1);
    }
    @DeleteMapping("/{id}")
    public void deleteRestaurantById(@PathVariable int id) {
        restaurantsService.deleteById(id);
    }
}
