CREATE TABLE opening_balance (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    amount NUMERIC(14,2) NOT NULL,
    reference_date DATE NOT NULL
);
