<div align="center">

# Kairos

### Planejamento financeiro pessoal, no momento certo.

O **Kairos** é uma plataforma de gestão financeira pessoal criada para transformar receitas, despesas, metas e patrimônio em uma visão simples, previsível e acionável.

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-1f6feb)
![Java](https://img.shields.io/badge/Java-17%2B-007396)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F)
![Flutter](https://img.shields.io/badge/Flutter-mobile-02569B)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-database-336791)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

</div>

---

## Visão do produto

O Kairos foi pensado para responder, de forma objetiva, às perguntas mais importantes do mês financeiro:

- Quanto já entrou?
- Quanto ainda vou receber?
- Quanto já foi pago?
- Quanto ainda preciso pagar?
- Quanto do meu saldo já está comprometido?
- Quanto realmente posso gastar?
- Quanto posso guardar ou investir?

Mais do que registrar movimentações, o objetivo do Kairos é antecipar decisões e dar previsibilidade ao usuário.

> **Registrar o passado, organizar o presente e projetar o futuro.**

---

## Principais funcionalidades

### Planejamento financeiro

- Receitas recebidas e previstas
- Despesas pagas e pendentes
- Gastos recorrentes
- Categorias financeiras
- Planejamento mensal
- Saldo projetado

### Controle e acompanhamento

- Dashboard mensal
- Visão de valores recebidos, previstos, pagos e pendentes
- Kanban financeiro
- Histórico mensal
- Fechamento financeiro do mês
- Controle de dívidas e parcelas

### Patrimônio e metas

- Registro de patrimônio
- Acompanhamento de investimentos
- Metas financeiras
- Definição de aportes
- Evolução patrimonial

### Alertas e automações

- Contas próximas do vencimento
- Receitas previstas ainda não confirmadas
- Compromissos atrasados
- Limites de gastos por categoria
- Alertas de saldo projetado

### Integrações futuras

- Integração com o assistente **Kai**
- Entrada de gastos por voz
- Consultas financeiras por linguagem natural
- IA local para análises financeiras
- Sugestões de alocação e acompanhamento de metas

---

## Arquitetura

O Kairos utiliza uma arquitetura centralizada em uma única API.

```text
                   PostgreSQL
                       ↑
                       │
                 Spring Boot API
               ↙        ↓         ↘
        JavaFX Desktop  Flutter   Kai / IA
```

O backend concentra as regras financeiras e a persistência dos dados.

Os clientes desktop e mobile consomem a mesma API, garantindo que uma alteração realizada em um dispositivo seja refletida nos demais.

---

## Plataformas

### Desktop

Aplicação para PC desenvolvida em **Java + JavaFX**.

Responsabilidades principais:

- Dashboard completo
- Planejamento mensal
- Gestão de receitas e despesas
- Dívidas e parcelas
- Metas e patrimônio
- Visualizações financeiras

### Mobile

Aplicação desenvolvida em **Flutter**, inicialmente direcionada ao Android.

Responsabilidades principais:

- Registro rápido de gastos
- Confirmação de receitas
- Consulta do saldo projetado
- Alertas
- Visão resumida do mês
- Ações rápidas

### Backend

API desenvolvida em **Java + Spring Boot**.

Responsável por:

- Regras de negócio
- Persistência dos dados
- Cálculos financeiros
- Planejamento mensal
- Alertas
- Metas
- Dívidas
- Patrimônio
- Integrações futuras

---

## Stack

| Camada | Tecnologia |
|---|---|
| Backend | Java 17+, Spring Boot |
| Desktop | JavaFX |
| Mobile | Flutter |
| Banco de dados | PostgreSQL |
| Persistência | Spring Data JPA |
| Migrations | Flyway |
| Build backend | Maven |
| API | REST |

---

## Estrutura do repositório

```text
Kairos/
├── src/                     # Backend Spring Boot
│   └── main/
│       ├── java/
│       └── resources/
│
├── desktop-java/            # Aplicação desktop JavaFX
│
├── mobile-flutter/          # Aplicação mobile Flutter
│
├── docs/                    # Documentação técnica
│
└── pom.xml
```

---

## Estado atual

O projeto está em fase de construção da base do MVP.

Já estão presentes:

- Estrutura inicial do backend Spring Boot
- Configuração para PostgreSQL
- Flyway para versionamento do banco
- Modelo inicial de lançamentos financeiros
- API inicial de receitas e despesas
- Base do cliente desktop em JavaFX
- Base do cliente mobile em Flutter
- Documentação da arquitetura

---

## Roadmap

### MVP

- [x] Base do backend
- [x] Estrutura de lançamentos financeiros
- [x] API inicial
- [x] Base JavaFX
- [x] Base Flutter
- [ ] Dashboard financeiro
- [ ] Planejamento mensal
- [ ] Receitas previstas
- [ ] Despesas recorrentes
- [ ] Kanban financeiro
- [ ] Radar financeiro
- [ ] Sistema de alertas
- [ ] Controle de dívidas
- [ ] Patrimônio
- [ ] Metas financeiras

### Evolução

- [ ] Fechamento mensal
- [ ] Histórico financeiro
- [ ] Regras automáticas de categorização
- [ ] Integração com Kai
- [ ] Entrada de gastos por voz
- [ ] IA local
- [ ] Análise de metas e patrimônio
- [ ] Integrações financeiras avançadas

---

## Princípios do projeto

O Kairos é desenvolvido com alguns princípios centrais:

- **Uma única fonte de verdade**
- **Regras financeiras no backend**
- **Previsibilidade antes de complexidade**
- **Multiplataforma desde a base**
- **Automação sem perder controle humano**
- **IA como apoio, não como fonte de cálculo**
- **Evolução incremental do MVP**

---

## Documentação

A documentação técnica da arquitetura está disponível em:

```text
docs/ARCHITECTURE.md
```

---

## Licença

Este projeto está licenciado sob a licença MIT.

---

<div align="center">

Desenvolvido por **Kelvin Rosendo**

**Kairos — tome decisões financeiras no momento certo.**

</div>
