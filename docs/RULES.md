# Regras financeiras — primeira versão

Este documento define o escopo inicial. Alterações de regra devem atualizar a documentação, os cálculos e os testes correspondentes.

## Modelo mínimo

- Uma posição de caixa consolidada, com valor inicial e data de referência. O valor é o saldo no início dessa data, antes das movimentações do dia. Não é uma receita.
- Lançamento: ID, tipo receita/despesa, descrição, valor positivo, data prevista, data de realização opcional, estado, categoria opcional, observação e datas de criação/alteração.
- Reaproveitar `FinancialEntry`, `INCOME`/`EXPENSE` e `PLANNED`/`SETTLED`/`CANCELLED` existentes, verificando o contrato antes de alterá-lo.
- Valores em BRL, com duas casas decimais, `BigDecimal` no Java e decimal no banco. Não usar ponto flutuante para cálculos monetários.
- Datas financeiras sem horário; usar referência de data consistente no backend, inicialmente America/Sao_Paulo. Instantes de auditoria são separados dessas datas.
- Não lançar movimentos anteriores à referência inicial nesta versão. Importação histórica e múltiplas contas ficam para depois.

## Estados e ações

- Incluir no planejamento não altera saldo realizado.
- Marcar receita como recebida ou despesa como paga muda para `SETTLED` e exige data de realização, não futura.
- Confirmar novamente o mesmo lançamento não duplica efeito financeiro. Repetição idêntica é inofensiva; alteração de realização usa o fluxo de edição.
- Reabrir remove a realização e retorna para `PLANNED`, recalculando os totais.
- Cancelar retira o lançamento dos cálculos sem removê-lo fisicamente. A interface deve explicar o impacto caso já esteja realizado.
- Atrasado é uma indicação derivada: planejado e data prevista anterior à data de consulta. Não exige um novo estado persistido.
- Na primeira versão, liquidação integral e um único valor por lançamento. Se o valor real diferir, editar antes de confirmar. Comparação histórica entre valor originalmente previsto e realizado não é suportada ainda.
- O campo recorrente existente não significa geração automática. Não oferecer essa promessa até implementar a recorrência.
- Criação deve ter proteção contra repetição de requisição, com identificador de operação e garantia no servidor; desabilitar o botão sozinho não resolve falhas de rede.

## Datas, lista e métricas

- A lista de planejamento do mês é filtrada pela data prevista. Informar a data real quando houver; ela pode pertencer a outro mês.
- Recebido e pago no mês usam a data de realização. Logo, esses totais podem incluir lançamentos previstos para outro mês; a interface deve permitir identificar sua origem.
- Pendentes do mês usam data prevista no mês. Pendências anteriores aparecem separadamente como atrasadas e também entram na projeção até o fim do mês.
- Saldo em uma data = saldo inicial + receitas realizadas desde a referência até essa data − despesas realizadas no mesmo intervalo.
- Para o mês atual, saldo atual é o saldo até hoje. Saldo projetado ao final do mês = saldo atual + receitas planejadas com data prevista até o fim do mês − despesas planejadas até o fim do mês, incluindo atrasados desde a referência.
- Para mês futuro, a projeção parte do saldo atual e inclui todos os pendentes até seu encerramento, inclusive dos meses intermediários. Mostrar o horizonte claramente.
- Para mês passado, mostrar saldo realizado no encerramento. Não apresentar a projeção de hoje como se fosse uma previsão histórica preservada.
- Dinheiro comprometido é o total pendente de despesas até o horizonte indicado. Receitas previstas não são dinheiro disponível hoje.
- Não chamar o saldo projetado de “valor seguro para gastar” nem exibir sugestão automática de investimento nesta versão.
- O saldo não reinicia na virada do mês; não criar um novo saldo inicial mensal que duplique os valores transportados.

## Exemplos de aceitação

1. Saldo inicial R$ 800, receita pendente R$ 500 e despesa pendente R$ 300 no horizonte: saldo atual R$ 800, projeção R$ 1.000.
2. Pagar os R$ 300: saldo atual R$ 500, despesa pendente R$ 0, projeção permanece R$ 1.000.
3. Receber os R$ 500: saldo atual R$ 1.000, receita pendente R$ 0, projeção permanece R$ 1.000.
4. Repetir a confirmação não altera esses valores.
5. Reabrir a despesa: saldo atual R$ 1.300, despesa pendente R$ 300, projeção R$ 1.000.
6. Cancelar essa despesa reaberta: saldo atual e projeção R$ 1.300.
7. Receita prevista em outubro, recebida em novembro: integra o planejamento de outubro e o realizado de novembro, sem duplicação de caixa.

Validar também lista vazia, saldo negativo, entradas inválidas, atrasados entre meses e edição de movimentação realizada. Testes usam data controlada para não depender do dia de execução.
