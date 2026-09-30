package com.kairos.finance;

import com.kairos.features.finance.model.*;
import com.kairos.features.finance.service.FinanceOverviewService;
import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class FinanceOverviewTest {
    private final LocalDate today = LocalDate.of(2026, 10, 15);
    private final YearMonth month = YearMonth.of(2026, 10);
    private final OpeningBalance balance = new OpeningBalance(new BigDecimal("800.00"), LocalDate.of(2026, 10, 1));
    private FinancialEntry entry(EntryType type, String amount, LocalDate date) {
        return new FinancialEntry(type, "Teste", "", new BigDecimal(amount), date, false, "");
    }
    @Test void settlementReopenAndCancelPreserveCorrectProjection() {
        var income = entry(EntryType.INCOME, "500.00", today);
        var expense = entry(EntryType.EXPENSE, "300.00", today);
        var entries = List.of(income, expense);
        assertSummary(entries, "800.00", "1000.00");
        expense.settle(today);
        assertSummary(entries, "500.00", "1000.00");
        income.settle(today);
        assertSummary(entries, "1000.00", "1000.00");
        income.settle(today);
        assertSummary(entries, "1000.00", "1000.00");
        expense.reopen();
        assertSummary(entries, "1300.00", "1000.00");
        expense.cancel();
        assertSummary(entries, "1300.00", "1300.00");
    }
    private void assertSummary(List<FinancialEntry> entries, String current, String projected) {
        var result = FinanceOverviewService.calculate(balance, entries, month, today);
        assertEquals(0, new BigDecimal(current).compareTo(result.current()));
        assertEquals(0, new BigDecimal(projected).compareTo(result.projected()));
    }
    @Test void futureMonthIncludesIntermediatePendingButPastUsesRealDate() {
        var income = entry(EntryType.INCOME, "500.00", today);
        var future = FinanceOverviewService.calculate(balance, List.of(income), month.plusMonths(1), today);
        assertEquals(0, new BigDecimal("1300").compareTo(future.projected()));
        income.settle(LocalDate.of(2026, 11, 2));
        var past = FinanceOverviewService.calculate(balance, List.of(income), month, LocalDate.of(2026, 11, 5));
        assertTrue(past.historical());
        assertEquals(0, new BigDecimal("800").compareTo(past.current()));
        var november = FinanceOverviewService.calculate(balance, List.of(income), month.plusMonths(1), LocalDate.of(2026,11,5));
        assertEquals(0, new BigDecimal("500").compareTo(november.received()));
    }
    @Test void missingBalanceRequiresSetup() {
        assertFalse(FinanceOverviewService.calculate(null, List.of(), month, today).configured());
    }
    @Test void overdueAndNegativeBalancesRemainVisible() {
        var expense = entry(EntryType.EXPENSE, "900.01", today.minusDays(5));
        assertSummary(List.of(expense), "800.00", "-100.01");
    }
}
