package com.kairos.features.finance.service;

import com.kairos.features.finance.dto.CreateFinancialEntryRequest;
import com.kairos.features.finance.model.FinancialEntry;
import com.kairos.features.finance.repository.FinancialEntryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@Service
public class FinancialEntryService {

    private final FinancialEntryRepository repository;

    public FinancialEntryService(FinancialEntryRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public FinancialEntry create(CreateFinancialEntryRequest request) {
        return repository.save(new FinancialEntry(
                request.type(),
                request.description(),
                request.category(),
                request.amount(),
                request.expectedDate(),
                request.recurring(),
                request.notes()
        ));
    }

    @Transactional(readOnly = true)
    public List<FinancialEntry> listMonth(YearMonth month) {
        return repository.findByExpectedDateBetweenOrderByExpectedDateAsc(
                month.atDay(1), month.atEndOfMonth());
    }

    @Transactional
    public FinancialEntry settle(UUID id, LocalDate date) {
        FinancialEntry entry = repository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Lançamento não encontrado"));
        entry.settle(date);
        return entry;
    }
}
