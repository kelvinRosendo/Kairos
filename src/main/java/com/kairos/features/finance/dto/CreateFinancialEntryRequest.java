package com.kairos.features.finance.dto;

import com.kairos.features.finance.model.EntryType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;
import java.time.LocalDate;

public record CreateFinancialEntryRequest(
        @NotNull EntryType type,
        @NotBlank @Size(max = 160) String description,
        @Size(max = 80) String category,
        @NotNull @DecimalMin(value = "0.01") @Digits(integer = 12, fraction = 2) BigDecimal amount,
        @NotNull LocalDate expectedDate,
        boolean recurring,
        @Size(max = 500) String notes
) {}
