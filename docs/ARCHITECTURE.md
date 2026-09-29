# Arquitetura do Kairos

O Kairos será um sistema financeiro pessoal multiplataforma com uma única fonte de verdade.

## Componentes

### Backend — Java + Spring Boot

Responsável por:

- regras de negócio;
- receitas e despesas;
- planejamento mensal;
- saldo projetado;
- dívidas;
- metas;
- patrimônio;
- alertas;
- futura integração com Kai e IA;
- persistência PostgreSQL.

### Desktop — Java + JavaFX

Aplicativo para PC.

Não acessa o PostgreSQL diretamente. Consome a API REST do backend.

Responsável por:

- dashboard financeiro;
- cadastro e edição de lançamentos;
- visão mensal;
- kanban de receitas e despesas;
- radar financeiro;
- patrimônio, dívidas e metas.

### Mobile — Flutter

Aplicativo para Android inicialmente, preparado para outras plataformas suportadas pelo Flutter.

Consome a mesma API REST do backend.

Responsável por:

- consultas rápidas;
- registro imediato de gastos;
- confirmação de receitas;
- alertas;
- dashboard resumido;
- ações rápidas.

## Fluxo

```text
                 PostgreSQL
                     ↑
                     │
               Spring Boot API
             ↙        ↓        ↘
      JavaFX PC   Flutter Mobile   Kai / IA
```

Nenhum cliente deve implementar as regras financeiras principais por conta própria.
As regras ficam no backend para evitar divergência entre PC, celular e Kai.

## Princípio

Registrar no celular deve refletir no PC e vice-versa sem sincronização manual.

## Estrutura inicial do repositório

```text
Kairos/
├── src/                  # backend Spring Boot
├── desktop-java/         # cliente JavaFX
├── mobile-flutter/       # cliente Flutter
└── docs/                 # arquitetura e documentação
```

Em uma etapa posterior, o backend poderá ser movido para uma pasta própria se o projeto crescer a ponto de justificar um monorepo modular completo.
