package com.kairos.features.finance.controller;

import com.kairos.features.finance.dto.CreateFinancialEntryRequest;
import com.kairos.features.finance.model.FinancialEntry;
import com.kairos.features.finance.service.FinancialEntryService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/entries")
public class FinancialEntryController {

    private final FinancialEntryService service;

    public FinancialEntryController(FinancialEntryService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public FinancialEntry create(@Valid @RequestBody CreateFinancialEntryRequest request) {
        return service.create(request);
    }

    @GetMapping
    public List<FinancialEntry> list(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM") YearMonth month) {
        return service.listMonth(month);
    }

    @PatchMapping("/{id}/settle")
    public FinancialEntry settle(
            @PathVariable UUID id,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return service.settle(id, date == null ? LocalDate.now() : date);
    }
}
