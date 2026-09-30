package com.kairos.features.finance.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "financial_entries")
public class FinancialEntry {

    @Id
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EntryType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EntryStatus status;

    @Column(nullable = false, length = 160)
    private String description;

    @Column(length = 80)
    private String category;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;

    @Column(name = "expected_date", nullable = false)
    private LocalDate expectedDate;

    @Column(name = "settled_date")
    private LocalDate settledDate;

    @Column(nullable = false)
    private boolean recurring;

    @Column(length = 500)
    private String notes;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    protected FinancialEntry() {}

    public FinancialEntry(EntryType type, String description, String category, BigDecimal amount,
                          LocalDate expectedDate, boolean recurring, String notes) {
        this.id = UUID.randomUUID();
        this.type = type;
        this.status = EntryStatus.PLANNED;
        this.description = description;
        this.category = category;
        this.amount = amount;
        this.expectedDate = expectedDate;
        this.recurring = recurring;
        this.notes = notes;
        this.createdAt = OffsetDateTime.now();
        this.updatedAt = this.createdAt;
    }

    public void settle(LocalDate date) {
        this.status = EntryStatus.SETTLED;
        this.settledDate = date;
        this.updatedAt = OffsetDateTime.now();
    }

    public void cancel() {
        this.status = EntryStatus.CANCELLED;
        this.updatedAt = OffsetDateTime.now();
    }

    public FinancialEntry(UUID id, EntryType type, String description, String category, BigDecimal amount,
                          LocalDate expectedDate, boolean recurring, String notes) {
        this(type, description, category, amount, expectedDate, recurring, notes);
        this.id = id;
    }

    public void reopen() {
        this.status = EntryStatus.PLANNED;
        this.settledDate = null;
        this.updatedAt = OffsetDateTime.now();
    }

    public void edit(String description, String category, BigDecimal amount, LocalDate expectedDate, String notes) {
        this.description = description;
        this.category = category;
        this.amount = amount;
        this.expectedDate = expectedDate;
        this.notes = notes;
        this.updatedAt = OffsetDateTime.now();
    }

    public UUID getId() { return id; }
    public EntryType getType() { return type; }
    public EntryStatus getStatus() { return status; }
    public String getDescription() { return description; }
    public String getCategory() { return category; }
    public BigDecimal getAmount() { return amount; }
    public LocalDate getExpectedDate() { return expectedDate; }
    public LocalDate getSettledDate() { return settledDate; }
    public boolean isRecurring() { return recurring; }
    public String getNotes() { return notes; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
}
