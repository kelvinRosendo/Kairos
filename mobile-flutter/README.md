# Kairos mobile

Aplicativo Flutter/Android com tema escuro, branco e cinza. O desktop continua no repositório, mas a prioridade atual é o celular.

## Abrir a visão do aplicativo

Na pasta `mobile-flutter`:

```powershell
flutter pub get
flutter run -d chrome --web-port 5173
```

Sem endereço de API, abre uma demonstração com dados fictícios, somente para leitura. O formulário pode ser visualizado, mas não salva na demonstração. A prévia web existe para revisão e desenvolvimento do mesmo código Flutter.

## Android

Conecte o celular com depuração USB autorizada e confira `flutter devices`:

```powershell
flutter run -d ID_DO_DISPOSITIVO
```

APK de desenvolvimento gerado em `build/app/outputs/flutter-apk/app-debug.apk`. Não é uma versão assinada para distribuição pública. HTTP local está permitido somente no manifesto debug.

## Conectar dados reais

1. Prepare PostgreSQL com um banco exclusivo `kairos` e credenciais próprias. Configure `DB_URL`, `DB_USER` e `DB_PASSWORD` no terminal do backend.
2. Na raiz do repositório, execute `mvn spring-boot:run` com Java 17+ e Maven. As migrations são aplicadas pelo Flyway. O backend escuta somente em `127.0.0.1:8080`.
3. Com Android conectado por USB, execute:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" reverse tcp:8080 tcp:8080
```

4. No app, abra **Conectar** e use `http://127.0.0.1:8080`. Alternativamente, inicie já configurado:

```powershell
flutter run -d ID_DO_DISPOSITIVO --dart-define=KAIROS_API_URL=http://127.0.0.1:8080
```

5. Configure o saldo inicial e sua data de referência antes de cadastrar lançamentos. O saldo é o valor no início desse dia, antes das movimentações.

O endereço informado pela interface dura somente a sessão. `--dart-define` mantém o endereço na compilação. Dados reais ficam no PostgreSQL; não há cache offline. O computador e o backend precisam estar ligados. Não exponha esta versão pessoal sem autenticação à internet. Para emulador, quando disponível, use `http://10.0.2.2:8080`.

A prévia no navegador pode usar `http://127.0.0.1:8080`; o backend permite CORS somente para as origens locais na porta 5173.

## Verificação

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Na raiz: `mvn test`. O teste de integração usa H2 temporário em modo PostgreSQL, aplica as migrations e valida a API. Ele não substitui teste com PostgreSQL real.

## Organização

- `lib/main.dart`: tema e inicialização.
- `lib/home.dart`: planejamento mensal, resumo, filtros e ações.
- `lib/entry_form.dart`: formulários de lançamento e saldo inicial.
- `lib/finance.dart`: modelos, transporte REST, apresentação monetária e demonstração isolada.

Cálculos financeiros reais ficam no backend. O cliente usa centavos inteiros para entrada/exibição e envia valores decimais exatos. Cada formulário de criação possui uma chave de operação reaproveitada em uma tentativa posterior, evitando duplicação pela mesma operação.

## Limitações atuais

Sem autenticação, notificações, recorrências automáticas, múltiplas contas, sincronização offline ou investimentos. A aba Próximos filtra pendências do mês selecionado; o resumo inclui pendências anteriores até o horizonte. A lista detalhada de atrasados de outros meses ainda precisa ser implementada. Edições simultâneas entre dispositivos ainda não têm controle de versão.

Validação física no Android, execução com PostgreSQL real e backup/restauração continuam pendentes. Consulte `../docs/DELIVERY_LOG.md`.
