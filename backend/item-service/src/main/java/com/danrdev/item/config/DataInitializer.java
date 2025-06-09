package com.danrdev.item.config;

import com.danrdev.item.model.category.Category;
import com.danrdev.item.repository.CategoryRepository;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.boot.context.event.ApplicationReadyEvent;

@Component
public class DataInitializer {

    private final CategoryRepository categoryRepository;

    public DataInitializer(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void initializeDefaultCategory() {
        String defaultName = "Other";
        if (!categoryRepository.existsByName(defaultName)) {
            Category category = new Category();
            category.setName(defaultName);
            categoryRepository.save(category);
        }
    }
}
