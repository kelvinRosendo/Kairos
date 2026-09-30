import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kairos_mobile/finance.dart';

void main() {
  test('Envia centavos exatos e datas sem horário à API', () async {
    final source =
        ApiSource('http://localhost:8080/', client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/entries');
      final body = jsonDecode(request.body);
      expect(body['amount'], '27.50');
      expect(body['expectedDate'], '2026-10-12');
      return http.Response('{}', 201);
    }));
    await source.save(Entry(
        id: '',
        type: 'EXPENSE',
        description: 'Lanche',
        amount: 2750,
        date: DateTime(2026, 10, 12)));
    source.close();
  });
  test('Erro do servidor não é tratado como sucesso', () async {
    final source = ApiSource('http://localhost:8080',
        client: MockClient((request) async => http.Response(
            '{"message":"Configure o saldo inicial primeiro."}', 400)));
    await expectLater(source.opening(0, DateTime(2026, 10)), throwsException);
    source.close();
  });
}
