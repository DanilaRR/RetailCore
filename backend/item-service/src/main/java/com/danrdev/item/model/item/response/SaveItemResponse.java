package com.danrdev.item.model.item.response;

import java.math.BigDecimal;

public record SaveItemResponse(Long id, String name, BigDecimal price, String category) {}
