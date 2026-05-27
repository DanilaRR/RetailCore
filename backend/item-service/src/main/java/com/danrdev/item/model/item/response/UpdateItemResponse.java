package com.danrdev.item.model.item.response;

import java.math.BigDecimal;

public record UpdateItemResponse(Long id, String name, BigDecimal price, Long categoryId) {}
