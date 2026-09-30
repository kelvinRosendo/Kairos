# Kairos — plano de execução

## Objetivo imediato

Entregar um caderno financeiro digital bonito e utilizável pelo Kelvin para organizar outubro de 2026. A primeira versão é pessoal, com prioridade mobile Flutter/Android e backend local: informar saldo inicial, planejar receitas e despesas com descrição, valor e data, confirmar recebimentos/pagamentos e acompanhar a previsão de sobra.

O planejamento completo continua sendo a visão de evolução. Não é requisito construir todos os módulos para começar a usar.

## Decisões da primeira versão

- Manter Java 17, Spring Boot, REST, PostgreSQL, Spring Data JPA, Flyway e Maven existentes.
- Priorizar Flutter/Android por decisão do usuário em 29/09/2026. Preservar JavaFX para depois; usar a prévia web do Flutter para revisão visual.
- Backend como única fonte dos cálculos; desktop não acessa o banco diretamente.
- Uso local por uma pessoa, em BRL, com uma posição consolidada de caixa. Sem login nesta entrega; API limitada ao computador local. Acesso remoto exige uma etapa própria de autenticação e proteção.
- Interface escura, branca e cinza, com destaque branco intenso e cores centralizadas para personalização futura.
- Entregar incrementos executáveis, sem reescrever a base inteira nem introduzir microserviços.
- Não publicar, integrar bancos ou adicionar IA nesta fase.

## Situação de partida

Inspeção dos arquivos em 30/09/2026: existem configurações Maven, PostgreSQL e Flyway, entidade `FinancialEntry`, serviço de criação/listagem mensal/liquidação e janela JavaFX inicial. Existem também estruturas antigas/paralelas de transações e usuários que precisam ser avaliadas antes de qualquer remoção.

Essa inspeção não confirma compilação, testes ou funcionamento em execução. O estado abaixo reflete a entrega mobile registrada em DELIVERY_LOG.md.

## Como executar

Uma sprint é um pacote de entrega, não uma promessa de duração. Executar na ordem, reaproveitando o que já funciona. O primeiro marco de uso real termina na Sprint 3; a Sprint 4 prepara a rotina de uso. Testes financeiros, tratamento de erros e revisão visual acompanham as entregas.

| Sprint | Entrega | Estado |
|---|---|---|
| 1 | Base executável e contrato financeiro mínimo | Parcial: testes passam; PostgreSQL real pendente |
| 2 | Tela mobile com identidade visual | Concluída para prévia e APK debug |
| 3 | Caderno financeiro integrado e utilizável | Parcial: REST implementado; validação Android + PostgreSQL pendente |
| 4 | Preparação para uso diário em outubro | Pendente: backup, abertura prática e uso real |
| 3B | Persistência offline e sincronização | Planejada: SQLite, fila durável e resolução de conflitos |
| 4B | Servidor doméstico Linux | Planejada: depende da preparação do PC pelo usuário |

### Atualização de prioridade — 30/09/2026

O usuário confirmou que o aplicativo abriu no Android físico. Falta validar dados reais de ponta a ponta. Também definiu funcionamento offline com sincronização posterior e planeja preparar um PC antigo com Linux como servidor, possivelmente no domingo.

Ordem de trabalho atual: concluir base PostgreSQL/API da Sprint 1 e jornada real da Sprint 3; executar Sprint 3B; concluir preparação de uso diário da Sprint 4. A Sprint 4B pode avançar quando o servidor estiver disponível. A interface da Sprint 2 já está entregue. Não é necessário esperar o servidor doméstico para desenvolver a persistência local.

Sprint 3B segue [OFFLINE_SYNC.md](OFFLINE_SYNC.md): armazenamento local, fila transacional, idempotência de todas as operações, versões/conflitos, estados visíveis de sincronização e testes de desconexão/reenvio. Não declarar concluída apenas porque o app consegue armazenar dados localmente.

Sprint 4B: configurar backend e PostgreSQL no Linux, inicialização automática, acesso autenticado apropriado, conexão do Android e backup/restauração. Distribuição Linux e mecanismo de acesso externo ainda não foram escolhidos. Não publicar serviços nem mudar permissões de rede como parte desta atualização documental.

## Sprint 1 — base executável e contrato mínimo

**Objetivo:** conseguir iniciar banco, backend e aplicativo Flutter, com regras e contratos claros.

Trabalho:

- Verificar versões instaladas, compilação e testes existentes; registrar bloqueios reais.
- Identificar o fluxo financeiro ativo e conflitos com código anterior. Não excluir código apenas por parecer duplicado.
- Confirmar as regras de [RULES.md](RULES.md) e documentar os contratos efetivamente implementados em `docs/API.md` e o modelo em `docs/DATABASE.md`.
- Preparar migrations incrementais para a posição inicial de caixa e eventuais campos necessários. Preservar dados e migrations já aplicadas.
- Implementar saldo inicial, edição, cancelamento e reversão da confirmação, reaproveitando a API de lançamentos.
- Implementar resumo financeiro no backend, com referência temporal e testes de saldo/projeção, repetição de confirmação e mudança de mês.
- Padronizar erros de validação e recurso não encontrado; configurar execução local sem exposição de rede.
- Documentar inicialização e configuração sem versionar segredos.

Concluída quando:

- Backend e aplicativo Flutter compilam e existe procedimento reproduzível para iniciar o ambiente.
- É possível criar, editar, confirmar, reabrir e cancelar um lançamento pela API e recuperar os dados após reinício.
- Os exemplos financeiros de RULES.md passam em testes automatizados pertinentes.
- API e banco estão documentados conforme a implementação, com limitações explícitas.

## Sprint 2 — interface mobile escura profissional

**Objetivo:** entregar a tela principal executável com a identidade visual escolhida.

Trabalho:

- Implementar o layout de [UI_UX.md](UI_UX.md), com estilos centralizados.
- Montar seleção de mês, resumo, filtros, lista e formulário de lançamento.
- Preparar estados vazio, carregando, erro, confirmação e validação.
- Usar dados de demonstração apenas se necessários, isolados e claramente identificados; nunca gravá-los no banco pessoal automaticamente.
- Separar apresentação, acesso à API e modelos de transporte, sem cálculos financeiros na camada visual.
- Inspecionar a janela renderizada, redimensionamento, teclado e legibilidade.

Concluída quando:

- A tela pode ser aberta e os componentes podem ser avaliados visualmente.
- O tema permanece confortável e legível; formulários e ações principais funcionam na demonstração.
- A entrega contém captura de tela, quando o ambiente permitir, e informa quais ações ainda dependem da integração.
- Trocar o destaque futuramente não exige alterar estilos espalhados por telas.

## Sprint 3 — caderno integrado

**Objetivo:** organizar outubro pelo aplicativo com dados reais.

Trabalho:

- Conectar a interface à API: saldo inicial, listagem, criação, edição, cancelamento, pagamento/recebimento e reversão.
- Atualizar resumo e lista após cada operação confirmada pelo servidor.
- Exibir próximos vencimentos e pendências atrasadas em uma seção simples; sem motor de notificações.
- Tratar indisponibilidade do backend, impedir cliques duplicados e preservar o formulário em caso de erro.
- Executar chamadas de rede fora da thread de interface.
- Retirar demonstrações do fluxo normal e validar a jornada completa.

Concluída quando:

- Kelvin consegue informar o saldo, cadastrar os ganhos e gastos de outubro, marcar os realizados e consultar a previsão.
- Fechar e abrir o aplicativo preserva os dados.
- Cancelar ou reabrir uma movimentação atualiza os totais corretamente.
- Falhas de conexão não exibem sucesso falso nem apagam o conteúdo digitado.
- A troca de mês respeita as datas e não reinicia o saldo artificialmente.

**Marco: primeira versão utilizável.**

## Sprint 4 — uso diário

**Objetivo:** tornar a abertura e a manutenção dos dados práticas.

Trabalho:

- Criar e verificar instruções ou um iniciador simples para abrir os componentes no Windows.
- Documentar backup e restauração do PostgreSQL; testar restauração em uma base separada.
- Revisar mensagens, foco, atalhos essenciais, valores em pt-BR e apresentação de datas.
- Conferir logs úteis sem exposição desnecessária das informações financeiras.
- Registrar limitações e problemas encontrados no uso, sem expandir automaticamente o escopo.

Concluída quando:

- O procedimento de abertura foi executado e documentado.
- Existe backup recuperável verificado sem sobrescrever a base pessoal.
- O roteiro manual da jornada principal passa, e problemas restantes estão registrados.

## Evolução após uso real

Priorizar a partir das necessidades encontradas: copiar lançamentos para outro mês e recorrências; categorias e orçamento; parcelas e dívidas; projeção diária e alertas; patrimônio e metas; fechamento mensal; Flutter e acesso seguro à mesma API; Kai, IA e Open Finance.

Cartões, investimentos e transferências exigem regras próprias para evitar dupla contagem. Não simulá-los como recursos completos na primeira versão.

## Coordenação

Usar [WORKFLOW.md](WORKFLOW.md) para gerar prompts e registrar entregas. Não iniciar a próxima sprint automaticamente quando o pedido for apenas uma sprint. Atualizar o estado com evidências; trabalho parcial permanece em andamento.

