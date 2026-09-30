package com.kairos.features.finance.service;

import com.kairos.features.finance.model.*;
import com.kairos.features.finance.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;

@Service
public class FinanceOverviewService {
    private final FinancialEntryRepository entries;
    private final OpeningBalanceRepository balances;
    public FinanceOverviewService(FinancialEntryRepository entries, OpeningBalanceRepository balances) {
        this.entries = entries; this.balances = balances;
    }
    public static LocalDate today() { return LocalDate.now(ZoneId.of("America/Sao_Paulo")); }
    public record Summary(boolean configured, BigDecimal current, BigDecimal projected,
        BigDecimal receivable, BigDecimal payable, BigDecimal received, BigDecimal paid,
        LocalDate asOf, LocalDate horizon, boolean historical) {}

    @Transactional(readOnly = true)
    public Summary summary(YearMonth month) {
        return calculate(balances.findById(1).orElse(null), entries.findAll(), month, today());
    }

    public static Summary calculate(OpeningBalance opening, List<FinancialEntry> entries, YearMonth month, LocalDate today) {
        boolean historical = month.isBefore(YearMonth.from(today));
        LocalDate asOf = historical ? month.atEndOfMonth() : today;
        LocalDate horizon = month.atEndOfMonth();
        if (opening == null || opening.getReferenceDate().isAfter(asOf))
            return new Summary(false, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                BigDecimal.ZERO, BigDecimal.ZERO, asOf, horizon, historical);
        BigDecimal current = opening.getAmount(), incoming = BigDecimal.ZERO, outgoing = BigDecimal.ZERO;
        BigDecimal received = BigDecimal.ZERO, paid = BigDecimal.ZERO;
        for (FinancialEntry entry : entries) {
            if (entry.getStatus() == EntryStatus.CANCELLED) continue;
            boolean income = entry.getType() == EntryType.INCOME;
            if (entry.getStatus() == EntryStatus.SETTLED) {
                LocalDate date = entry.getSettledDate();
                if (date == null || date.isBefore(opening.getReferenceDate())) continue;
                if (!date.isAfter(asOf)) current = income ? current.add(entry.getAmount()) : current.subtract(entry.getAmount());
                if (YearMonth.from(date).equals(month) && !date.isAfter(today)) {
                    if (income) received = received.add(entry.getAmount()); else paid = paid.add(entry.getAmount());
                }
            } else if (!historical && !entry.getExpectedDate().isBefore(opening.getReferenceDate()) && !entry.getExpectedDate().isAfter(horizon)) {
                if (income) incoming = incoming.add(entry.getAmount()); else outgoing = outgoing.add(entry.getAmount());
            }
        }
        return new Summary(true, current, current.add(incoming).subtract(outgoing), incoming, outgoing,
            received, paid, asOf, horizon, historical);
    }

    @Transactional
    public OpeningBalance configure(BigDecimal amount, LocalDate date) {
        if (date.isAfter(today())) throw new IllegalArgumentException("A data inicial não pode estar no futuro.");
        for (FinancialEntry e : entries.findAll()) {
            if (e.getStatus() != EntryStatus.CANCELLED && (e.getExpectedDate().isBefore(date)
                || (e.getSettledDate() != null && e.getSettledDate().isBefore(date))))
                throw new IllegalArgumentException("A data inicial deve ser anterior ou igual aos lançamentos existentes.");
        }
        return balances.save(new OpeningBalance(amount, date));
    }
}
