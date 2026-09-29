package com.kairos.features.finance.repository;

import com.kairos.features.finance.model.EntryStatus;
import com.kairos.features.finance.model.EntryType;
import com.kairos.features.finance.model.FinancialEntry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface FinancialEntryRepository extends JpaRepository<FinancialEntry, UUID> {
    List<FinancialEntry> findByExpectedDateBetweenOrderByExpectedDateAsc(LocalDate start, LocalDate end);
    List<FinancialEntry> findByTypeAndStatusAndExpectedDateBetween(
            EntryType type, EntryStatus status, LocalDate start, LocalDate end);
}
