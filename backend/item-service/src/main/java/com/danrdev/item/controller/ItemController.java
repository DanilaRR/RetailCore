package com.danrdev.item.controller;

import com.danrdev.item.model.item.request.SaveItemRequest;
import com.danrdev.item.model.item.request.UpdateItemRequest;
import com.danrdev.item.model.item.response.DeleteItemResponse;
import com.danrdev.item.model.item.response.ErrorResponse;
import com.danrdev.item.model.item.response.SaveItemResponse;
import com.danrdev.item.model.item.response.ViewItemResponse;
import com.danrdev.item.service.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/items")
public class ItemController {

    @Autowired
    private ItemService itemService;

    @GetMapping
    public ResponseEntity<List<ViewItemResponse>> listItems() {
        List<ViewItemResponse> items = itemService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ViewItemResponse> viewItem(@PathVariable Long id) {
        return itemService.getItemById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/upload")
    public ResponseEntity<?> uploadItem(
            @RequestParam("name") String name,
            @RequestParam(value = "category", required = false) String categoryName,
            @RequestParam("price") String price) throws IOException {

        BigDecimal priceValue;
        try {
            priceValue = new BigDecimal(price);
            if (priceValue.compareTo(BigDecimal.ZERO) <= 0) {
                return ResponseEntity.badRequest().body(new ErrorResponse("Price must be greater than zero"));
            }
        } catch (NumberFormatException ex) {
            return ResponseEntity.badRequest().body(new ErrorResponse("Invalid price format"));
        }

        SaveItemRequest request = new SaveItemRequest(name, categoryName, priceValue);
        SaveItemResponse response = itemService.saveItem(request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<DeleteItemResponse> deleteItem(@PathVariable Long id) {
        DeleteItemResponse response = itemService.deleteItem(id);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Void> updateItem(@PathVariable Long id, @RequestBody UpdateItemRequest request) {
        itemService.updateItem(id, request);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

    @PostMapping("/{id}/upload-image")
    public ResponseEntity<?> uploadImage(@PathVariable Long id, @RequestBody Map<String, String> request) {
        try {
            String imageData = request.get("imageData");
            itemService.saveItemImage(id, imageData);
            return ResponseEntity.ok(new ErrorResponse("Image uploaded successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/image")
    public ResponseEntity<?> getImage(@PathVariable Long id) {
        return itemService.getItemImage(id)
                .map(image -> {
                    Map<String, String> response = new java.util.HashMap<>();
                    response.put("imageData", image);
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
