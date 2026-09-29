CREATE TABLE financial_entries (
    id UUID PRIMARY KEY,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    description VARCHAR(160) NOT NULL,
    category VARCHAR(80),
    amount NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
    expected_date DATE NOT NULL,
    settled_date DATE,
    recurring BOOLEAN NOT NULL DEFAULT FALSE,
    notes VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_financial_entries_expected_date
    ON financial_entries(expected_date);

CREATE INDEX idx_financial_entries_type_status
    ON financial_entries(type, status);
