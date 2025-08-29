package com.online.food.service;

import com.online.food.model.Restaurants;
import com.online.food.repository.RestaurantsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RestaurantsService {

    @Autowired
    private RestaurantsRepository restaurantsRepository;

    public List<Restaurants> findAll() {
        return restaurantsRepository.findAll();
    }

    public Restaurants save(Restaurants restaurants) {
        return restaurantsRepository.save(restaurants);
    }

    public Restaurants findById(Integer id) {
        return restaurantsRepository.findById(id).get();
    }

    public void deleteById(Integer id) {
        try {
            restaurantsRepository.deleteById(id);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public Restaurants update(Restaurants restaurants) {
        Restaurants restaurants1 = new Restaurants();
        restaurants1.setRestaurantName(restaurants.getRestaurantName());
        restaurants1.setEmail(restaurants.getEmail());
        restaurants1.setPhoneNumber(restaurants.getPhoneNumber());
        restaurants1.setRestaurantAddress(restaurants.getRestaurantAddress());
        return restaurantsRepository.save(restaurants);
    }
}
