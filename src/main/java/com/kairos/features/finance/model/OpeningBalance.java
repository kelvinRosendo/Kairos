package com.kairos.features.finance.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "opening_balance")
public class OpeningBalance {
    @Id
    private Integer id = 1;
    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;
    @Column(name = "reference_date", nullable = false)
    private LocalDate referenceDate;
    protected OpeningBalance() {}
    public OpeningBalance(BigDecimal amount, LocalDate date) { this.amount = amount; this.referenceDate = date; }
    public BigDecimal getAmount() { return amount; }
    public LocalDate getReferenceDate() { return referenceDate; }
}
