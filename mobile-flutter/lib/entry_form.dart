import 'package:flutter/material.dart';
import 'finance.dart';

class EntryForm extends StatefulWidget {
  final FinanceSource source;
  final DateTime month;
  final Entry? entry;
  const EntryForm(
      {super.key, required this.source, required this.month, this.entry});
  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final form = GlobalKey<FormState>();
  final requestId = operationId();
  late final description =
      TextEditingController(text: widget.entry?.description ?? '');
  late final amount = TextEditingController(
      text: widget.entry == null
          ? ''
          : decimal(widget.entry!.amount).replaceAll('.', ','));
  late final category =
      TextEditingController(text: widget.entry?.category ?? '');
  late final notes = TextEditingController(text: widget.entry?.notes ?? '');
  late String type = widget.entry?.type ?? 'EXPENSE';
  late DateTime date = widget.entry?.date ??
      (monthKey(widget.month) == monthKey(DateTime.now())
          ? DateTime.now()
          : widget.month);
  bool saving = false;
  String? error;
  @override
  void dispose() {
    for (final c in [description, amount, category, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.source.save(
          Entry(
              id: widget.entry?.id ?? requestId,
              type: type,
              description: description.text.trim(),
              amount: parseMoney(amount.text)!,
              date: date,
              category: category.text.trim(),
              notes: notes.text.trim()),
          editing: widget.entry != null);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => error =
            '${e.toString().replaceFirst('Exception: ', '')}\nSe houve falha de rede, confira a lista antes de tentar criar novamente.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !saving,
      child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 28),
          child: Form(
              key: form,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        widget.entry == null
                            ? 'Uma nova anotação'
                            : 'Editar lançamento',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                        widget.source.demo
                            ? 'Prévia do formulário · conecte seus dados para salvar.'
                            : 'Organize agora. Tenha clareza depois.',
                        style: const TextStyle(color: Color(0xFFADB3BD))),
                    const SizedBox(height: 24),
                    SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'EXPENSE',
                              label: Text('Despesa'),
                              icon: Icon(Icons.north_east)),
                          ButtonSegment(
                              value: 'INCOME',
                              label: Text('Receita'),
                              icon: Icon(Icons.south_west))
                        ],
                        selected: {
                          type
                        },
                        onSelectionChanged: saving || widget.entry != null
                            ? null
                            : (value) => setState(() => type = value.first)),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: amount,
                        enabled: !saving,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Valor',
                            prefixText: 'R\$ ',
                            hintText: '0,00'),
                        validator: (v) => parseMoney(v ?? '') == null
                            ? 'Informe um valor positivo, como 99,90.'
                            : null),
                    const SizedBox(height: 14),
                    TextFormField(
                        controller: description,
                        enabled: !saving,
                        maxLength: 160,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                            labelText: 'Descrição',
                            hintText: 'Ex.: internet, salário, mercado'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Dê um nome ao lançamento.'
                            : null),
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                final selected = await showDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    helpText: 'Data prevista',
                                    cancelText: 'Voltar',
                                    confirmText: 'Escolher');
                                if (selected != null && mounted) {
                                  setState(() => date = selected);
                                }
                              },
                        icon:
                            const Icon(Icons.calendar_today_outlined, size: 18),
                        label: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                                'Previsto para ${shortDate(date)}/${date.year}'))),
                    const SizedBox(height: 14),
                    TextFormField(
                        controller: category,
                        enabled: !saving,
                        maxLength: 80,
                        decoration: const InputDecoration(
                            labelText: 'Categoria (opcional)',
                            hintText: 'Ex.: Casa')),
                    TextFormField(
                        controller: notes,
                        enabled: !saving,
                        maxLength: 500,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Observação (opcional)')),
                    if (widget.entry?.settled == true)
                      const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                              'Este lançamento já foi realizado. Alterar o valor também altera o saldo.',
                              style: TextStyle(color: Color(0xFFADB3BD)))),
                    if (error != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    const SizedBox(height: 8),
                    FilledButton(
                        onPressed: saving || widget.source.demo ? null : save,
                        child:
                            Text(saving ? 'Salvando…' : 'Salvar lançamento')),
                  ]))));
}

class BalanceForm extends StatefulWidget {
  final FinanceSource source;
  const BalanceForm({super.key, required this.source});
  @override
  State<BalanceForm> createState() => _BalanceFormState();
}

class _BalanceFormState extends State<BalanceForm> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  DateTime date = DateTime(DateTime.now().year, DateTime.now().month);
  bool saving = false;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !saving,
      child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 28),
          child: Form(
              key: form,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Seu ponto de partida',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    const Text(
                        'Quanto você tinha no início desta data, antes dos lançamentos do dia? Alterar esse valor recalcula seus saldos. Não é uma receita.'),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: amount,
                        enabled: !saving,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: const InputDecoration(
                            labelText: 'Saldo inicial',
                            prefixText: 'R\$ ',
                            hintText: '0,00'),
                        validator: (v) =>
                            parseMoney(v ?? '', signed: true) == null
                                ? 'Informe um valor, como 800,00.'
                                : null),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                final selected = await showDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    helpText: 'Data de referência',
                                    cancelText: 'Voltar',
                                    confirmText: 'Escolher');
                                if (selected != null && mounted) {
                                  setState(() => date = selected);
                                }
                              },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text('${shortDate(date)}/${date.year}')),
                    if (error != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!form.currentState!.validate()) return;
                                setState(() {
                                  saving = true;
                                  error = null;
                                });
                                try {
                                  await widget.source.opening(
                                      parseMoney(amount.text, signed: true)!,
                                      date);
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => error = e
                                        .toString()
                                        .replaceFirst('Exception: ', ''));
                                  }
                                } finally {
                                  if (mounted) setState(() => saving = false);
                                }
                              },
                        child: Text(
                            saving ? 'Salvando…' : 'Salvar saldo inicial')),
                  ]))));
}
