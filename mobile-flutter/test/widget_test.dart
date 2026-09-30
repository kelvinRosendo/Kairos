import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos_mobile/main.dart';
import 'package:kairos_mobile/finance.dart';

class FailingSource extends DemoSource {
  @override
  bool get demo => false;
  @override
  Future<List<Entry>> entries(DateTime month) async =>
      throw Exception('Servidor indisponível');
}

class SavingSource extends DemoSource {
  bool fail = true;
  Entry? saved;
  @override
  bool get demo => false;
  @override
  Future<void> save(Entry entry, {bool editing = false}) async {
    saved = entry;
    if (fail) throw Exception('Sem conexão');
  }
}

void main() {
  testWidgets('Mantém formulário e chave de operação após falha ao salvar',
      (tester) async {
    final source = SavingSource();
    await tester.pumpWidget(KairosApp(source: source));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Novo lançamento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '27,50');
    await tester.enterText(find.byType(TextFormField).at(1), 'Lanche');
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, 'Salvar lançamento'));
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar lançamento'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sem conexão'), findsOneWidget);
    expect(find.text('Lanche'), findsOneWidget);
    final firstId = source.saved!.id;
    expect(source.saved!.amount, 2750);
    expect(firstId, isNotEmpty);
    source.fail = false;
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, 'Salvar lançamento'));
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar lançamento'));
    await tester.pumpAndSettle();
    expect(source.saved!.id, firstId);
    expect(find.text('Lançamento salvo.'), findsOneWidget);
  });
  test('Valores brasileiros preservam centavos sem ponto flutuante', () {
    expect(parseMoney('1.234,56'), 123456);
    expect(parseMoney('0,01'), 1);
    expect(parseMoney('10,001'), null);
    expect(parseMoney('10.5'), null);
    expect(parseMoney('-1,00'), null);
    expect(parseMoney('-1,00', signed: true), -100);
    expect(money(123456), 'R\$ 1.234,56');
    expect(decimal(9990), '99.90');
  });
  for (final width in [360.0, 430.0]) {
    testWidgets('Tela mobile, filtros e formulário em $width', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(KairosApp(source: DemoSource()));
      await tester.pumpAndSettle();
      expect(find.text('Seu mês, sob controle.'), findsOneWidget);
      expect(find.text('Demonstração · dados fictícios'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Ocultar valores'));
      await tester.pumpAndSettle();
      expect(find.text('R\$ ••••'), findsWidgets);
      await tester.tap(find.byTooltip('Novo lançamento'));
      await tester.pumpAndSettle();
      expect(find.text('Uma nova anotação'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
          find.byType(SingleChildScrollView).last, const Offset(0, -550));
      await tester.pumpAndSettle();
      final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Salvar lançamento'));
      expect(button.onPressed, isNull);
    });
  }
  testWidgets('Falha de conexão apresenta recuperação sem saldo falso',
      (tester) async {
    await tester.pumpWidget(KairosApp(source: FailingSource()));
    await tester.pumpAndSettle();
    expect(find.text('Não conseguimos atualizar'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Saldo atual'), findsNothing);
  });
}
