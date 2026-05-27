package com.danrdev.item.controller;

import com.danrdev.item.model.category.request.CreateCategoryRequest;
import com.danrdev.item.model.category.response.CreateCategoryResponse;
import com.danrdev.item.service.CategoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private final CategoryService service;

    public CategoryController(CategoryService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<CreateCategoryResponse>> listCategories() {
        return ResponseEntity.ok(service.getAllCategories());
    }

    @PostMapping
    public ResponseEntity<CreateCategoryResponse> createCategory(@RequestBody CreateCategoryRequest request) {
        return ResponseEntity.ok(service.createCategory(request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id) {
        service.deleteCategory(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/name")
    public ResponseEntity<CreateCategoryResponse> renameCategory(
            @PathVariable Long id,
            @RequestBody String newName
    ) {
        return ResponseEntity.ok(service.renameCategory(id, newName));
    }
}
