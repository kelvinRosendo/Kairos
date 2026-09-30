package com.kairos.features.finance.controller;

import com.kairos.features.finance.model.OpeningBalance;
import com.kairos.features.finance.service.FinanceOverviewService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.time.*;

@RestController
@RequestMapping("/api/finance")
public class FinanceOverviewController {
    private final FinanceOverviewService service;
    public FinanceOverviewController(FinanceOverviewService service) { this.service = service; }
    public record BalanceRequest(@NotNull @Digits(integer = 12, fraction = 2) BigDecimal amount, @NotNull LocalDate referenceDate) {}
    @GetMapping("/summary")
    public FinanceOverviewService.Summary summary(@RequestParam String month) { return service.summary(YearMonth.parse(month)); }
    @PutMapping("/opening-balance")
    public OpeningBalance configure(@Valid @RequestBody BalanceRequest request) { return service.configure(request.amount(), request.referenceDate()); }
}
