import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

String operationId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

String isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String monthKey(DateTime d) => isoDate(d).substring(0, 7);
String shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
int cents(Object? value) {
  final m = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$').firstMatch('$value');
  if (m == null) throw const FormatException('Valor monetário inválido');
  final n = int.parse(m[2]!) * 100 + int.parse((m[3] ?? '').padRight(2, '0'));
  return m[1] == '-' ? -n : n;
}

String decimal(int n) =>
    '${n < 0 ? '-' : ''}${n.abs() ~/ 100}.${(n.abs() % 100).toString().padLeft(2, '0')}';
int? parseMoney(String value, {bool signed = false}) {
  final input = value.trim().replaceAll('R\$', '').replaceAll(' ', '');
  if (!RegExp(r'^-?(?:\d+|\d{1,3}(?:\.\d{3})+)(?:,\d{1,2})?$').hasMatch(input)) {
    return null;
  }
  final normalized = value
      .trim()
      .replaceAll('R\$', '')
      .replaceAll(' ', '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  try {
    final n = cents(normalized);
    return n.abs() > 99999999999999 || (!signed && n <= 0) ? null : n;
  } on FormatException {
    return null;
  }
}

String money(int n) {
  final whole = (n.abs() ~/ 100)
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  return '${n < 0 ? '− ' : ''}R\$ $whole,${(n.abs() % 100).toString().padLeft(2, '0')}';
}

class Entry {
  final String id, type, description, status, category, notes;
  final int amount;
  final DateTime date;
  final DateTime? settledDate;
  const Entry(
      {required this.id,
      required this.type,
      required this.description,
      required this.amount,
      required this.date,
      this.status = 'PLANNED',
      this.category = '',
      this.notes = '',
      this.settledDate});
  bool get income => type == 'INCOME';
  bool get settled => status == 'SETTLED';
  bool get cancelled => status == 'CANCELLED';
  bool get overdue =>
      !settled &&
      !cancelled &&
      date.isBefore(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day));
  String get label => cancelled
      ? 'Cancelado'
      : settled
          ? (income ? 'Recebido' : 'Pago')
          : overdue
              ? 'Atrasado'
              : income
                  ? 'A receber'
                  : 'A pagar';
  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
      id: j['id'],
      type: j['type'],
      description: j['description'],
      amount: cents(j['amount']),
      date: DateTime.parse(j['expectedDate']),
      status: j['status'],
      category: j['category'] ?? '',
      notes: j['notes'] ?? '',
      settledDate:
          j['settledDate'] == null ? null : DateTime.parse(j['settledDate']));
  Map<String, dynamic> toJson() => {
        'type': type,
        'description': description,
        'amount': decimal(amount),
        'expectedDate': isoDate(date),
        'category': category,
        'notes': notes,
        'recurring': false
      };
}

class Overview {
  final bool configured, historical;
  final int current, projected, receivable, payable;
  const Overview(
      {this.configured = true,
      this.historical = false,
      this.current = 0,
      this.projected = 0,
      this.receivable = 0,
      this.payable = 0});
  factory Overview.fromJson(Map<String, dynamic> j) => Overview(
      configured: j['configured'],
      historical: j['historical'],
      current: cents(j['current']),
      projected: cents(j['projected']),
      receivable: cents(j['receivable']),
      payable: cents(j['payable']));
}

abstract class FinanceSource {
  bool get demo;
  Future<List<Entry>> entries(DateTime month);
  Future<Overview> overview(DateTime month);
  Future<void> save(Entry entry, {bool editing = false});
  Future<void> action(String id, String action, {DateTime? date});
  Future<void> opening(int amount, DateTime date);
  void close() {}
}

class ApiSource extends FinanceSource {
  final String baseUrl;
  final http.Client client;
  ApiSource(this.baseUrl, {http.Client? client})
      : client = client ?? http.Client();
  @override
  bool get demo => false;
  Future<dynamic> request(String method, String path,
      [Map<String, dynamic>? data, String? idempotencyKey]) async {
    final uri = Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');
    final req = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json';
    if (data != null) req.body = jsonEncode(data);
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      req.headers['Idempotency-Key'] = idempotencyKey;
    }
    try {
      final response = await client
          .send(req)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message =
            'Não foi possível concluir a operação (${response.statusCode}).';
        try {
          message = (jsonDecode(response.body) as Map)['message'] ?? message;
        } catch (_) {}
        throw Exception(message);
      }
      return response.body.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw Exception(
          'O servidor demorou a responder. Verifique a conexão e tente novamente.');
    } on http.ClientException {
      throw Exception(
          'Não foi possível conectar ao Kairos. Confira se o servidor está aberto.');
    }
  }

  @override
  Future<List<Entry>> entries(DateTime month) async =>
      ((await request('GET', '/api/entries?month=${monthKey(month)}')) as List)
          .map((j) => Entry.fromJson(j))
          .toList();
  @override
  Future<Overview> overview(DateTime month) async => Overview.fromJson(
      await request('GET', '/api/finance/summary?month=${monthKey(month)}'));
  @override
  Future<void> save(Entry entry, {bool editing = false}) async {
    await request(
        editing ? 'PUT' : 'POST',
        '/api/entries${editing ? '/${entry.id}' : ''}',
        entry.toJson(),
        editing ? null : entry.id);
  }

  @override
  Future<void> action(String id, String action, {DateTime? date}) async {
    await request('PATCH',
        '/api/entries/$id/$action${date == null ? '' : '?date=${isoDate(date)}'}');
  }

  @override
  Future<void> opening(int amount, DateTime date) async {
    await request('PUT', '/api/finance/opening-balance',
        {'amount': decimal(amount), 'referenceDate': isoDate(date)});
  }

  @override
  void close() => client.close();
}

// Read-only fixture: never mixed with the personal database or used for real calculations.
class DemoSource extends FinanceSource {
  @override
  bool get demo => true;
  @override
  Future<List<Entry>> entries(DateTime m) async => [
        Entry(
            id: '1',
            type: 'INCOME',
            description: 'Salário',
            amount: 320000,
            date: DateTime(m.year, m.month, 5),
            category: 'Trabalho',
            status: 'SETTLED'),
        Entry(
            id: '2',
            type: 'EXPENSE',
            description: 'Aluguel',
            amount: 95000,
            date: DateTime(m.year, m.month, 8),
            category: 'Casa',
            status: 'SETTLED'),
        Entry(
            id: '3',
            type: 'EXPENSE',
            description: 'Internet',
            amount: 9990,
            date: DateTime(m.year, m.month, 12),
            category: 'Casa'),
        Entry(
            id: '4',
            type: 'INCOME',
            description: 'Projeto freelance',
            amount: 65000,
            date: DateTime(m.year, m.month, 15),
            category: 'Trabalho'),
        Entry(
            id: '5',
            type: 'EXPENSE',
            description: 'Mercado',
            amount: 42000,
            date: DateTime(m.year, m.month, 18),
            category: 'Alimentação'),
        Entry(
            id: '6',
            type: 'EXPENSE',
            description: 'Academia',
            amount: 12000,
            date: DateTime(m.year, m.month, 20),
            category: 'Saúde'),
      ];
  @override
  Future<Overview> overview(DateTime month) async => const Overview(
      current: 225000, projected: 226010, receivable: 65000, payable: 63990);
  @override
  Future<void> save(Entry entry, {bool editing = false}) async =>
      throw Exception('Conecte seus dados para salvar.');
  @override
  Future<void> action(String id, String action, {DateTime? date}) async =>
      throw Exception('Conecte seus dados para alterar.');
  @override
  Future<void> opening(int amount, DateTime date) async =>
      throw Exception('Conecte seus dados para salvar.');
}
