package com.danrdev.item.model.item.request;

import java.math.BigDecimal;

public record SaveItemRequest(String name, String categoryName, BigDecimal price) {}