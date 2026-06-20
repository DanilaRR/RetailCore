package com.danrdev.item.model.item.request;

import java.math.BigDecimal;

public record UpdateItemRequest(Long id, String newName, BigDecimal newPrice, String newCategoryName) {
}