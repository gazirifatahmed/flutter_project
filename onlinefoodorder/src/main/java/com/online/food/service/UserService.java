package com.online.food.service;


import com.online.food.model.User;
import com.online.food.repository.UserRepository;
import com.online.food.util.PasswordUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;


    public User saveUser(User user) {
        user.setPassword(PasswordUtil.hash(user.getPassword()));
        return userRepository.save(user);
    }

    public User login(User user) {
        String password = user.getPassword();
        user = userRepository.findByUsername(user.getUsername());
        if (user != null && PasswordUtil.verify(password, user.getPassword())) {
            return user;
        }
        throw new RuntimeException("Invalid username or password");
    }

    public User updateUser(int id, User user) {
        User userExists = userRepository.findById(id).orElse(null);
        if (userExists == null) {
            throw new RuntimeException("User not found");
        }
        userExists.setUsername(user.getUsername());
        userExists.setEmail(user.getEmail());
        userExists.setPhone(user.getPhone());
        userExists.setAddress(user.getAddress());
        userExists.setRole(user.getRole());
        return userRepository.save(userExists);
    }

    public void deleteUser(int id) {
        User userExists = userRepository.findById(id).orElse(null);
        if (userExists == null) {
            throw new RuntimeException("User not found");
        }
        userRepository.delete(userExists);
    }
}
