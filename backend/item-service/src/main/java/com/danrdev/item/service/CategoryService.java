package com.danrdev.item.service;

import com.danrdev.item.model.category.Category;
import com.danrdev.item.model.category.request.CreateCategoryRequest;
import com.danrdev.item.model.category.response.CreateCategoryResponse;
import com.danrdev.item.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.NoSuchElementException;

@Service
public class CategoryService {

    private final CategoryRepository repository;

    public CategoryService(CategoryRepository repository) {
        this.repository = repository;
    }

    public CreateCategoryResponse createCategory(CreateCategoryRequest request) {
        if (repository.existsByName(request.name())) {
            throw new IllegalArgumentException("Category already exists");
        }

        Category category = new Category();
        category.setName(request.name());
        Category saved = repository.save(category);

        return toResponse(saved);
    }

    public void deleteCategory(Long categoryId) {
        if (!repository.existsById(categoryId)) {
            throw new NoSuchElementException("Category not found");
        }
        repository.deleteById(categoryId);
    }

    public CreateCategoryResponse renameCategory(Long categoryId, String newName) {
        Category category = repository.findById(categoryId)
                .orElseThrow(() -> new NoSuchElementException("Category not found"));

        if (repository.existsByName(newName)) {
            throw new IllegalArgumentException("Category name already exists");
        }

        category.setName(newName);
        Category updated = repository.save(category);
        return toResponse(updated);
    }

    private CreateCategoryResponse toResponse(Category category) {
        return new CreateCategoryResponse(category.getId(), category.getName());
    }
}
