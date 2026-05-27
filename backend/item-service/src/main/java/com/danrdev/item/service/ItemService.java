package com.danrdev.item.service;

import com.danrdev.item.model.category.Category;
import com.danrdev.item.model.item.Item;
import com.danrdev.item.model.item.request.SaveItemRequest;
import com.danrdev.item.model.item.request.UpdateItemRequest;
import com.danrdev.item.model.item.response.DeleteItemResponse;
import com.danrdev.item.model.item.response.SaveItemResponse;
import com.danrdev.item.model.item.response.ViewItemResponse;
import com.danrdev.item.repository.CategoryRepository;
import com.danrdev.item.repository.ItemRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ItemService {

    private final ItemRepository itemRepository;
    private final CategoryRepository categoryRepository;

    @Autowired
    public ItemService(ItemRepository itemRepository, CategoryRepository categoryRepository) {
        this.itemRepository = itemRepository;
        this.categoryRepository = categoryRepository;
    }

    public SaveItemResponse saveItem(SaveItemRequest request) throws IOException {
        if (request.price() == null || request.price().signum() <= 0) {
            throw new IllegalArgumentException("Price must be greater than zero");
        }

        Item item = new Item();
        item.setName(request.name());
        item.setPrice(request.price());

        String categoryName = request.categoryName();
        Category category = (categoryName != null && !categoryName.isBlank())
                ? categoryRepository.findByName(categoryName)
                .orElseThrow(() -> new IllegalArgumentException("Category not found: " + categoryName))
                : categoryRepository.findByName("Other")
                .orElseThrow(() -> new IllegalStateException("Default category 'Other' not found"));

        item.setCategory(category);
        itemRepository.save(item);

        return new SaveItemResponse(item.getId(), item.getName(), item.getPrice(), category.getName());
    }

    @Transactional
    public void updateItem(Long itemId, UpdateItemRequest request) {
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("Item not found"));

        if (request.newName() != null) {
            item.setName(request.newName());
        }
        if (request.newPrice() != null) {
            item.setPrice(request.newPrice());
        }
        if (request.newCategoryId() != null
                && !request.newCategoryId().equals(item.getCategory().getId())) {
            Category category = categoryRepository.findById(request.newCategoryId())
                    .orElseThrow(() -> new EntityNotFoundException("Category not found"));
            item.setCategory(category);
        }
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
