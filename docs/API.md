# API financeira atual

Base: `http://127.0.0.1:8080`. Valores decimais em BRL; datas `YYYY-MM-DD`; mês `YYYY-MM`. API pessoal local, sem autenticação.

| Método | Caminho | Função |
|---|---|---|
| PUT | `/api/finance/opening-balance` | Define `{amount, referenceDate}` antes dos lançamentos |
| GET | `/api/finance/summary?month=2026-10` | Resumo calculado no servidor |
| GET | `/api/entries?month=2026-10` | Lista por data prevista |
| POST | `/api/entries` | Cria lançamento planejado |
| PUT | `/api/entries/{id}` | Edita descrição, valor, categoria, data prevista e observação |
| PATCH | `/api/entries/{id}/settle?date=2026-10-12` | Confirma realização integral |
| PATCH | `/api/entries/{id}/reopen` | Retorna ao planejamento |
| PATCH | `/api/entries/{id}/cancel` | Cancela e retira dos cálculos |

Criação/edição: `{type, description, amount, expectedDate, category, notes, recurring}`. Tipo `INCOME` ou `EXPENSE`. O tipo não pode ser alterado por edição. Recorrência não é gerada automaticamente.

POST aceita `Idempotency-Key` com UUID. O cliente mobile mantém a mesma chave enquanto o formulário estiver aberto: repetição idêntica retorna o registro existente; conteúdo diferente para a mesma chave é rejeitado. A chave é o ID persistido do lançamento. Consumidores sem chave não têm essa proteção.

Resumo: `configured`, `current`, `projected`, `receivable`, `payable`, `received`, `paid`, `asOf`, `horizon`, `historical`. Não somar novamente os pagamentos ao saldo atual. Para mês passado, a projeção corresponde ao realizado no encerramento, sem reconstrução de previsão histórica.

Erros de negócio: HTTP 400 com `message`. Recurso ausente: 404. Valores têm até 12 dígitos inteiros e duas casas decimais. Realização futura e datas anteriores ao saldo inicial são rejeitadas.

CORS liberado somente para a prévia local na porta 5173. Android por USB pode usar `adb reverse`; nenhuma abertura de rede é necessária.
