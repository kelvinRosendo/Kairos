# Registro de entregas

## 30/09/2026 — decisões após teste no celular

Kelvin confirmou instalação e execução no Android físico. Isso valida a abertura da interface; integração real Android + API + PostgreSQL permanece pendente.

Registrados o servidor Linux doméstico planejado e o requisito de salvar alterações offline para sincronizar depois. Arquitetura e roadmap atualizados com Sprints 3B/4B e OFFLINE_SYNC.md. Apenas documentação alterada nesta etapa; persistência local e sincronização ainda não foram implementadas.

## 29/09/2026 — Codex — primeiro incremento mobile

**Direção:** usuário antecipou Flutter/Android em relação ao JavaFX. A arquitetura Spring Boot + PostgreSQL permanece. Nenhuma publicação ou commit foi realizado.

### O que foi feito e por quê

- Estrutura Android e web gerada com o SDK Flutter já instalado. A web permite revisar a mesma interface sem emulador.
- Tema escuro, branco e cinza; cartões de saldo/projeção, navegação mensal, filtros, ocultação de valores, pendências do mês, formulário, detalhes e ações. Material localizado em pt-BR.
- Demonstração visual somente para leitura, identificada e isolada dos dados reais. Sem servidor configurado, não há promessa de salvamento.
- Cliente REST com prazo de resposta, erros visíveis, campos preservados após falha e chave estável por formulário para repetir a criação.
- Backend ampliado com posição inicial, resumo financeiro, edição, cancelamento e reabertura. Cálculos reais permanecem no Java; o Flutter apenas apresenta valores em centavos.
- Migration V2 para saldo inicial. V1 e código legado preservados.
- Backend limitado a loopback, conexão Android por encaminhamento USB e CORS restrito à prévia local.
- README mobile, API, banco, direção visual e roadmap atualizados.

### Como foi validado

- Flutter 3.47.4 / Dart 3.13.3 disponíveis; Android toolchain verificado.
- `flutter analyze`: sem problemas após os ajustes finais.
- `flutter test`: 7 testes passaram. Entrada monetária, contrato REST, erro de API, layout em 360/430 pixels, formulário de demonstração e recuperação do formulário após falha de salvamento.
- `flutter build apk --debug`: APK gerado em `mobile-flutter/build/app/outputs/flutter-apk/app-debug.apk`.
- Backend compilado e `mvn test`: 5 testes passaram (4 financeiros + 1 integração HTTP via MockMvc).
- Teste de integração executou migrations e fluxo de saldo inicial → criação → repetição sem duplicar → confirmação → reabertura → cancelamento, além de rejeitar precisão monetária inválida.
- Integração usa H2 temporário em modo PostgreSQL; não foram usados dados pessoais. Não equivale a validação em PostgreSQL real.
- Prévia Flutter renderizada e inspecionada no navegador, incluindo largura de 390 pixels, navegação para outubro e formulário. Captura em `screenshots/kairos-mobile.png`.
- Maven não estava no PATH: usada cópia oficial 3.9.9 no diretório temporário `kairos-build-tools`, sem instalação global.

### Estado das sprints

- Sprint 1 parcial: contratos/código/testes prontos; PostgreSQL real e reinício persistente ainda não validados.
- Sprint 2 concluída para a primeira visão mobile/preview e APK debug.
- Sprint 3 parcial: integração REST implementada/testada por componentes; falta validar Flutter + API + PostgreSQL juntos em Android.
- Sprint 4 pendente: backup/restauração e abertura prática para uso diário.

### Limitações e próximos passos

Nenhum Android conectado e nenhum emulador configurado foram encontrados. Não há PostgreSQL escutando na porta padrão 5432. Por isso o aplicativo abre em demonstração por padrão, e o APK ainda não foi executado em dispositivo físico nesta tarefa.

Para começar a usar dados pessoais: preparar banco, iniciar backend, conectar Android por USB, executar `adb reverse`, configurar a conexão e o saldo inicial. Instruções em `mobile-flutter/README.md`.

Não há cache offline, autenticação, notificações, geração de recorrências, controle de edição simultânea ou histórico de auditoria completo. A aba Próximos mostra o mês selecionado; pendências anteriores entram no resumo, mas ainda não têm seção própria. O resumo lê todos os registros, aceitável neste incremento pessoal. Persistência de endereço via interface é somente por sessão; um endereço pode ser definido no build com `--dart-define`.

Revisar com Kelvin: composição visual, fluxo do cadastro, organização da aba Próximos e necessidade de funcionar sem o computador. Funcionamento totalmente independente do backend seria uma mudança de arquitetura que ainda não foi aplicada.
