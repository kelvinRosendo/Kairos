<h1 align="center">⏱️ Kairos</h1>

<p align="center">
  <b>Tome as decisões financeiras certas no momento certo</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-em%20desenvolvimento-yellow" />
  <img src="https://img.shields.io/badge/java-17+-blue" />
  <img src="https://img.shields.io/badge/spring%20boot-3.x-brightgreen" />
  <img src="https://img.shields.io/badge/license-MIT-lightgrey" />
</p>

---

## 🚀 Sobre o Projeto

O **Kairos** é um sistema de gestão financeira pessoal desenvolvido com **Java + Spring Boot**, focado em ajudar usuários a organizarem suas finanças e tomarem decisões mais inteligentes no momento certo.

A aplicação permite planejar o mês financeiro, controlar gastos, registrar entradas e saídas e acompanhar a evolução do dinheiro ao longo do tempo.

---

## 🧠 Ideia Central

> Kairos não é apenas sobre registrar dinheiro — é sobre tomar melhores decisões financeiras.

---

## 🎯 Funcionalidades

- 📅 Planejamento financeiro mensal  
- 💸 Registro de receitas e despesas  
- 📊 Controle de orçamento  
- 🎯 Definição de metas financeiras  
- 🔐 Gestão de usuários  

---

## 🧱 Arquitetura

O projeto segue uma estrutura moderna baseada em:

- Feature-Based Architecture  
- Clean Architecture (adaptada)  

### 🔄 Fluxo da aplicação

Controller → Service → Repository → Database

---

## 🗄️ Banco de Dados

- PostgreSQL  
- Flyway (versionamento de banco)  

### 📌 Entidades principais

- User  
- Account  
- Budget  
- Transaction  

---

## ⚙️ Tecnologias Utilizadas

- ☕ Java 17+  
- 🌱 Spring Boot  
- 🗄️ PostgreSQL  
- 🔄 Flyway  
- 🧰 Maven  

---

# 📂 Estrutura do Projeto Kairos

```
KAIROS/
│
└── src/
    ├── main/
    │   ├── java/com/kairos/
    │   │   ├── core/
    │   │   │   ├── config/
    │   │   │   ├── exception/
    │   │   │   ├── security/
    │   │   │   ├── transaction/
    │   │   │   │   ├── controller/
    │   │   │   │   ├── model/
    │   │   │   │   ├── repository/
    │   │   │   │   └── service/
    │   │   │   └── utils/
    │   │   │
    │   │   ├── features/
    │   │   │   └── budget/
    │   │   │       ├── model/
    │   │   │       └── service/
    │   │   │
    │   │   ├── controller/
    │   │   ├── dto/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   ├── user/
    │   │   │   └── model/
    │   │   ├── infra/
    │   │   ├── shared/
    │   │   └── KairosApplication.java
    │   │
    │   └── resources/
    │       └── db/
    │           └── migration/
    │
    └── test/
```
---

## 🛠️ Como Rodar o Projeto

```bash
git clone https://github.com/kelvinRosendo/kairos.git
cd kairos
mvn spring-boot:run
```

## 🚧 Status do Projeto

🟡 Em desenvolvimento

- A arquitetura base já foi definida e o projeto está evoluindo com a implementação das funcionalidades principais.

🔮 Roadmap
 [] Estrutura base do projeto
 [] Implementação de usuários
 [] Sistema de transações
 [] Controle de orçamento

---

## 🔐 Licença
Este projeto está sob a licença MIT.

--- 

👨‍💻 Autor
Desenvolvido por Kelvin Rosendo
