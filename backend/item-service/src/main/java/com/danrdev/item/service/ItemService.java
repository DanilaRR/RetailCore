package com.danrdev.item.service;

import com.danrdev.item.exception.GlobalExceptionHandler;
import com.danrdev.item.model.category.Category;
import com.danrdev.item.model.category.request.SaveCategoryRequest;
import com.danrdev.item.model.category.response.CreateCategoryResponse;
import com.danrdev.item.model.item.Item;
import com.danrdev.item.model.item.request.DeleteItemRequest;
import com.danrdev.item.model.item.request.SaveItemRequest;
import com.danrdev.item.model.item.request.UpdateItemRequest;
import com.danrdev.item.model.item.response.DeleteItemResponse;
import com.danrdev.item.model.item.response.SaveItemResponse;
import com.danrdev.item.model.item.response.UpdateItemResponse;
import com.danrdev.item.model.item.response.ViewItemResponse;
import com.danrdev.item.repository.CategoryRepository;
import com.danrdev.item.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ItemService {

    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    public SaveItemResponse saveItem(SaveItemRequest request) throws IOException {
        if (request.price() == null || request.price().signum() <= 0) {
            throw new IllegalArgumentException("Price must be greater than zero");
        }

        Item item = new Item();
        item.setName(request.name());
        item.setPrice(request.price());

        String categoryName = request.categoryName();
        Optional<Category> categoryOptional = categoryRepository.findByName(categoryName);
        if (categoryOptional.isEmpty()) {
            throw new NoSuchElementException("Category not found: " + categoryName);
        }
        item.setCategory(categoryOptional.get());

        Item savedItem = itemRepository.save(item);
        return new SaveItemResponse(savedItem.getId(), savedItem.getName());
    }

    @Transactional
    public void updateItem(Long itemId, UpdateItemRequest request) {
        Optional<Item> optional = itemRepository.findById(itemId);
        if (optional.isEmpty()) {
            throw new RuntimeException("Item not found with ID: " + itemId);
        }

        Item item = optional.get();
        item.setName(request.name());
        item.setPrice(request.price());

        String categoryName = request.categoryName();
        Optional<Category> categoryOptional = categoryRepository.findByName(categoryName);
        if (categoryOptional.isEmpty()) {
            throw new NoSuchElementException("Category not found: " + categoryName);
        }
        item.setCategory(categoryOptional.get());

        itemRepository.save(item);
    }

    public DeleteItemResponse deleteItem(Long id) {
        Optional<Item> optional = itemRepository.findById(id);
        if (optional.isEmpty()) {
            throw new RuntimeException("Item not found with ID: " + id);
        }

        itemRepository.deleteById(id);
        return new DeleteItemResponse(id, "Deleted successfully");
    }

    public Optional<ViewItemResponse> getItemById(Long id) {
        return itemRepository.findById(id)
                .map(this::toViewResponse);
    }

    public List<ViewItemResponse> getAllItems() {
        return itemRepository.findAll()
                .stream()
                .map(this::toViewResponse)
                .collect(Collectors.toList());
    }

    private ViewItemResponse toViewResponse(Item item) {
        return new ViewItemResponse(
                item.getId(),
                item.getName(),
                item.getPrice(),
                item.getCategory().getName()
        );
    }
}
