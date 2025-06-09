package com.danrdev.security.user;


import com.danrdev.security.model.User;
import com.danrdev.security.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String input) throws UsernameNotFoundException {

        User user = userRepository.findByEmail(input)
                .or(() -> userRepository.findByUsername(input))
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email or username: " + input));

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getEmail()) // Use email as the principal name
                .password(user.getPassword())
                .authorities(Collections.emptyList())
                .build();
    }
}

