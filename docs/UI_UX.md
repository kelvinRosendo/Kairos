# Interface — Kairos

## Direção

Um caderno financeiro digital profissional, confortável e simples. Tema escuro com branco e cinza; branco intenso como destaque luminoso discreto. A beleza faz parte da primeira entrega.

## Paleta inicial

| Papel | Cor inicial |
|---|---|
| Fundo | `#101113` |
| Superfície | `#181A1D` |
| Superfície elevada | `#202328` |
| Borda discreta | `#30343B` |
| Texto principal | `#F5F7FA` |
| Texto secundário | `#ADB3BD` |
| Destaque | `#F5F7FA` |
| Texto sobre destaque | `#101113` |

Centralizar os papéis de cor no tema Flutter; aplicar o mesmo princípio ao JavaFX futuro. Preparar mudança futura do destaque sem implementar um editor de temas agora. Não depender apenas de cor para indicar receita, despesa, erro ou estado.

## Tela principal

- Lateral compacta com marca Kairos e Planejamento ativo; não preencher o menu com funcionalidades inexistentes.
- Cabeçalho com mês/ano, anterior/próximo e ação “Novo lançamento”.
- Resumo com saldo atual e projeção em evidência; a receber e a pagar como apoio. Rótulos adaptados ao horizonte conforme RULES.md.
- Lista principal com descrição, tipo, data prevista, valor e situação; data real disponível quando aplicável.
- Filtros Todos, Receitas e Despesas, com filtro de situação se necessário.
- Pequena seção de pendências atrasadas/próximos vencimentos, sem transformar o radar em outro módulo.
- Formulário curto: tipo, descrição, valor e data; categoria e observação opcionais.
- Ações com nomes explícitos: “Marcar como pago”, “Marcar como recebido”, “Editar”, “Reabrir” e “Cancelar lançamento”.
- Configuração do saldo inicial acessível e com explicação da data de referência.

## Interação e acabamento

- Priorizar alinhamento, respiro e hierarquia; evitar excesso de cartões e brilho.
- Brilho sutil no destaque ativo; nenhum brilho em texto corrido.
- Tipografia de sistema legível, escala consistente e números monetários alinhados.
- Usar pt-BR: R$ 1.240,00 e datas locais; manter ano visível na seleção mensal.
- Prever janela inicial de aproximadamente 1200 × 800 e comportamento utilizável em 960 × 640 com rolagem quando necessária.
- Foco de teclado visível, ordem de tabulação coerente e ações acessíveis sem mouse.
- Erros próximos aos campos; salvar não fecha o formulário se a API falhar.
- Distinguir carregamento, lista vazia, erro de conexão e sucesso real.
- Cancelamento de lançamento realizado deve explicar a alteração do saldo; reabrir permite corrigir uma confirmação acidental.
- Dados demonstrativos devem ser identificados e separados de dados pessoais.

## Verificação visual

Inspecionar a interface executada: estado vazio, lista preenchida, descrição longa, valores grandes/negativos, formulário inválido, foco por teclado e backend indisponível. Registrar captura quando possível; se não houver execução visual no ambiente, declarar a limitação em vez de afirmar validação.

## Prioridade mobile — 29/09/2026

A execução começou pelo Flutter/Android a pedido do usuário. Adaptar a proposta desktop: barra superior compacta, conteúdo em uma coluna, cartões de resumo, navegação inferior Meu mês / Próximos e botão flutuante de criação. Formulários abrem em painel inferior rolável com ajuste para teclado. A lateral e os requisitos de janela desktop ficam para a etapa JavaFX.

A prévia foi inspecionada em 390 × 844; testes de widgets cobrem 360 e 430 pixels. Branco/cinza são os destaques; mensagens de erro podem usar cor sem depender exclusivamente dela. O seletor de data usa pt-BR.
