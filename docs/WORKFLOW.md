# Trabalho com Codex e Open Code

## Fonte de contexto

Antes de implementar, ler README.md, docs/ROADMAP.md, docs/RULES.md, docs/UI_UX.md e docs/ARCHITECTURE.md, além das instruções locais aplicáveis. Conferir o código e o estado do Git; documentação não substitui evidência de funcionamento.

O responsável pode ser Codex ou Open Code. Evitar dois executores alterando os mesmos arquivos simultaneamente. Não pressupor que o outro executor tem acesso ao histórico da conversa.

## Ciclo de uma sprint

1. Solicitar o prompt da sprint ou pedir sua execução diretamente.
2. Conferir os pré-requisitos e o que já foi implementado; não repetir trabalho concluído.
3. Implementar apenas o escopo solicitado, preservando alterações existentes do usuário.
4. Executar verificações adequadas e registrar resultados reais.
5. Atualizar o estado em ROADMAP.md e registrar a entrega em docs/DELIVERY_LOG.md.
6. Apresentar feedback técnico para Kelvin revisar, ajustar e decidir o próximo incremento.

Decisões internas rotineiras podem ser tomadas pelo executor e explicadas depois. Mudanças de stack, regras financeiras ou ampliação material do escopo devem ser discutidas. Não fazer commit, push, publicação ou limpeza destrutiva sem pedido correspondente.

## Modelo de prompt para implementação

Copiar o bloco abaixo e substituir o número antes de enviar ao executor. O prompt específico deve incluir qualquer decisão posterior que ainda não esteja documentada.

```text
Implemente a Sprint [N] do Kairos conforme docs/ROADMAP.md.

Contexto: aplicação pessoal para organizar outubro de 2026, começando
com mobile Flutter/Android bonito e simples, backend Spring Boot e PostgreSQL.
Tema escuro com branco/cinza e destaque branco intenso. Evolução incremental.

Leia README.md, docs/ROADMAP.md, docs/RULES.md, docs/UI_UX.md,
docs/ARCHITECTURE.md e instruções locais aplicáveis. Inspecione o código
e o estado do Git antes de editar. Reaproveite a implementação existente.

Execute somente o escopo da sprint indicada e seus pré-requisitos necessários.
Preserve trabalho existente. Não adicione funcionalidades futuras nem troque
a stack. Regras financeiras ficam no backend. Preserve os dados e use
migrations incrementais. Não faça commit, push ou publicação.

Valide os critérios de aceitação com testes e/ou execução apropriados.
Para interface, inspecione a tela executada quando o ambiente permitir.
Declare verificações que não conseguiu realizar e o motivo.

Atualize o estado da sprint em docs/ROADMAP.md e registre a entrega
em docs/DELIVERY_LOG.md. Não marque concluída se faltarem critérios.

Ao terminar, explique: o que fez; como implementou; por que escolheu essa
solução; arquivos relevantes; como executar e testar; resultados das
verificações; limitações e decisões que Kelvin pode querer revisar.
Não inicie a próxima sprint automaticamente.
```

## Formato do feedback técnico

- **Resultado:** comportamento que já pode ser utilizado.
- **Implementação e motivos:** alterações e decisões relevantes, sem apenas listar arquivos.
- **Como conferir:** passos/comandos de execução, pré-requisitos e comportamento esperado.
- **Verificação:** testes e inspeções realmente executados, com resultado.
- **Limitações:** pendências, riscos concretos e pontos que precisam de escolha do desenvolvedor.
- **Próximo passo:** próximo incremento recomendado, sem iniciá-lo fora do pedido.

## Registro de entrega

Cada entrada em DELIVERY_LOG.md deve conter data, sprint, executor, estado, resumo das alterações, decisões, verificações e pendências. Nunca registrar credenciais ou dados financeiros pessoais nos exemplos.

