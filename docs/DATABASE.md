# Modelo de dados — incremento mobile

## financial_entries (V1)

UUID, tipo, estado, descrição, categoria opcional, valor decimal (14,2), data prevista, data de realização, recorrente, observações e instantes de criação/alteração. Estados operacionais: PLANNED, SETTLED, CANCELLED. OVERDUE é legado no enum; atraso na interface é derivado da data.

O UUID de uma criação mobile é a chave estável de operação. Cancelamentos são preservados. Reabrir limpa a data de realização. Editar valor realizado altera os saldos correspondentes. Não há pagamento parcial, trilha completa de auditoria ou versionamento otimista nesta entrega.

## opening_balance (V2)

Registro único (`id = 1`) com `amount NUMERIC(14,2)` e `reference_date DATE`. Representa a posição consolidada antes dos movimentos do dia de referência, não uma receita mensal. Aceita saldo negativo.

## Persistência e cálculo

PostgreSQL continua sendo o banco da aplicação, com Flyway e validação JPA. Totais são calculados em consulta no backend; não há totais derivados persistidos. Para este volume pessoal, o resumo lê os lançamentos existentes; otimização por consultas agregadas pode ser feita quando necessária.

H2 existe somente no escopo de testes, com banco temporário. As migrations passaram nele; execução em PostgreSQL real permanece pendente de ambiente.
