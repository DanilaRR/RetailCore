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
import java.io.IOException;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    return new SaveItemResponse(savedItem.getId(), savedItem.getName(), savedItem.getPrice(),
        savedItem.getCategory().getName());
  }

  @Transactional
  public void updateItem(Long itemId, UpdateItemRequest request) {
    Optional<Item> optional = itemRepository.findById(itemId);
    if (optional.isEmpty()) {
      throw new RuntimeException("Item not found with ID: " + itemId);
    }

    Item item = optional.get();
    item.setName(request.newName());
    item.setPrice(request.newPrice());

    String categoryName = request.newCategoryName();
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
    return itemRepository.findById(id).map(this::toViewResponse);
  }

  public List<ViewItemResponse> getAllItems() {
    return itemRepository.findAll().stream().map(this::toViewResponse).collect(Collectors.toList());
  }

  private ViewItemResponse toViewResponse(Item item) {
    return new ViewItemResponse(item.getId(), item.getName(), item.getPrice(), item.getCategory().getName());
  }

  @Transactional
  public void saveItemImage(Long itemId, String imageData) {
    Optional<Item> optional = itemRepository.findById(itemId);
    if (optional.isEmpty()) {
      throw new NoSuchElementException("Item not found with ID: " + itemId);
    }

    // Validate image data
    validateImageData(imageData);

    Item item = optional.get();
    item.setImageData(imageData);
    itemRepository.save(item);
  }

  public Optional<String> getItemImage(Long itemId) {
    return itemRepository.findById(itemId).map(Item::getImageData);
  }

  private void validateImageData(String imageData) {
    if (imageData == null || imageData.isEmpty()) {
      throw new IllegalArgumentException("Image data cannot be empty");
    }

    // Extract base64 data (remove data URI prefix if present)
    String base64Data = imageData;
    if (imageData.contains(",")) {
      base64Data = imageData.split(",")[1];
    }

    // Check size (2MB limit)
    // Base64 encoded size is roughly 33% larger than binary
    long estimatedBinarySize = (long) (base64Data.length() * 0.75);
    long maxSizeBytes = 2 * 1024 * 1024; // 2MB
    if (estimatedBinarySize > maxSizeBytes) {
      throw new IllegalArgumentException("Image size exceeds 2MB limit");
    }

    // Check format (JPG or PNG)
    if (!imageData.contains("image/jpeg") && !imageData.contains("image/png")) {
      throw new IllegalArgumentException("Only JPG and PNG formats are supported");
    }
  }
}
