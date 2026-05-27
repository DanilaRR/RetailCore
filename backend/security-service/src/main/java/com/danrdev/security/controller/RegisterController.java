package com.danrdev.security.controller;

import com.danrdev.security.model.User;
import com.danrdev.security.repository.UserRepository;
import com.danrdev.security.request.RegisterRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:5173")
public class RegisterController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody RegisterRequest registerRequest) {
        // Check if the user already exists
        if (userRepository.existsByUsername(registerRequest.username())) {
            return ResponseEntity.badRequest().body("Username is already taken");
        }
        if (userRepository.existsByEmail(registerRequest.email())) {
            return ResponseEntity.badRequest().body("Email is already taken");
        }

        // Create a new user and encode the password
        User user = new User();
        user.setUsername(registerRequest.username());
        user.setPassword(passwordEncoder.encode(registerRequest.password()));
        user.setEmail(registerRequest.email());

        // Save the user to the database
        userRepository.save(user);

        return ResponseEntity.ok("User registered successfully");
    }

}
