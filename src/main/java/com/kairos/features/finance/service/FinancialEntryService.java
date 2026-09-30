package com.kairos.features.finance.service;

import com.kairos.features.finance.dto.CreateFinancialEntryRequest;
import com.kairos.features.finance.model.FinancialEntry;
import com.kairos.features.finance.repository.FinancialEntryRepository;
import com.kairos.features.finance.repository.OpeningBalanceRepository;
import com.kairos.features.finance.model.EntryStatus;
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
    private final OpeningBalanceRepository balances;

    public FinancialEntryService(FinancialEntryRepository repository, OpeningBalanceRepository balances) {
        this.repository = repository;
        this.balances = balances;
    }

    @Transactional
    public FinancialEntry create(CreateFinancialEntryRequest request, UUID operationId) {
        validateDate(request.expectedDate());
        UUID id = operationId == null ? UUID.randomUUID() : operationId;
        var existing = repository.findById(id);
        if (existing.isPresent()) {
            var e = existing.get();
            if (e.getType() != request.type() || !e.getDescription().equals(request.description())
                || e.getAmount().compareTo(request.amount()) != 0 || !e.getExpectedDate().equals(request.expectedDate())
                || !java.util.Objects.equals(e.getCategory(), request.category()) || !java.util.Objects.equals(e.getNotes(), request.notes()))
                throw new IllegalArgumentException("Esta operação já foi registrada. Atualize a lista antes de editar.");
            return e;
        }
        return repository.save(new FinancialEntry(
                id,
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
        validateDate(date);
        if (date.isAfter(FinanceOverviewService.today())) throw new IllegalArgumentException("A realização não pode estar no futuro.");
        FinancialEntry entry = repository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Lançamento não encontrado"));
        if (entry.getStatus() == EntryStatus.CANCELLED) throw new IllegalArgumentException("Reabra o lançamento antes de confirmar.");
        if (entry.getStatus() == EntryStatus.SETTLED) return entry;
        entry.settle(date);
        return entry;
    }

    private void validateDate(LocalDate date) {
        var balance = balances.findById(1).orElseThrow(() -> new IllegalArgumentException("Configure o saldo inicial primeiro."));
        if (date.isBefore(balance.getReferenceDate())) throw new IllegalArgumentException("A data não pode ser anterior ao saldo inicial.");
    }

    @Transactional
    public FinancialEntry edit(UUID id, CreateFinancialEntryRequest request) {
        validateDate(request.expectedDate());
        var entry = repository.findById(id).orElseThrow(NoSuchElementException::new);
        if (entry.getType() != request.type()) throw new IllegalArgumentException("O tipo não pode ser alterado. Cancele e crie outro lançamento.");
        entry.edit(request.description(), request.category(), request.amount(), request.expectedDate(), request.notes());
        return entry;
    }

    @Transactional
    public FinancialEntry changeState(UUID id, boolean cancel) {
        var entry = repository.findById(id).orElseThrow(NoSuchElementException::new);
        if (cancel) entry.cancel(); else entry.reopen();
        return entry;
    }
}
