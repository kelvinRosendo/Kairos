import 'package:flutter/material.dart';
import 'finance.dart';
import 'entry_form.dart';

const muted = Color(0xFFADB3BD);
const months = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro'
];

class HomePage extends StatefulWidget {
  final FinanceSource? source;
  const HomePage({super.key, this.source});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FinanceSource source;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  List<Entry> entries = [];
  Overview? summary;
  String? error;
  bool loading = true, busy = false, hideAmounts = false;
  String filter = 'ALL';
  int tab = 0, generation = 0;
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    const url = String.fromEnvironment('KAIROS_API_URL');
    source = widget.source ?? (url.isEmpty ? DemoSource() : ApiSource(url));
    load();
  }

  @override
  void dispose() {
    source.close();
    scroll.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final request = ++generation;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result =
          await Future.wait([source.entries(month), source.overview(month)]);
      if (!mounted || request != generation) return;
      setState(() {
        entries = result[0] as List<Entry>;
        summary = result[1] as Overview;
        loading = false;
      });
    } catch (e) {
      if (!mounted || request != generation) return;
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void notify(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  String amount(int value) => hideAmounts ? 'R\$ ••••' : money(value);
  Future<void> connect() async {
    final url = await showDialog<String>(
        context: context,
        builder: (_) => ConnectionDialog(
            initial: source is ApiSource
                ? (source as ApiSource).baseUrl
                : 'http://127.0.0.1:8080'));
    if (url == null || !mounted) return;
    source.close();
    source = ApiSource(url);
    await load();
  }

  Future<void> edit([Entry? entry]) async {
    if (!source.demo && summary?.configured != true) {
      await opening();
      return;
    }
    final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => EntryForm(source: source, month: month, entry: entry));
    if (saved == true && mounted) {
      notify('Lançamento salvo.');
      await load();
    }
  }

  Future<void> opening() async {
    if (source.demo) {
      await connect();
      return;
    }
    final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => BalanceForm(source: source));
    if (result == true && mounted) await load();
  }

  Future<void> act(Entry entry, String action) async {
    if (source.demo) {
      notify('Exemplo visual. Conecte seus dados para alterar.');
      return;
    }
    DateTime? date;
    if (action == 'settle') {
      date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          helpText: entry.income ? 'Data do recebimento' : 'Data do pagamento',
          cancelText: 'Voltar',
          confirmText: 'Confirmar');
      if (date == null || !mounted) return;
    } else {
      final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(action == 'cancel'
                      ? 'Cancelar lançamento?'
                      : 'Reabrir lançamento?'),
                  content: Text(
                      '${entry.description}\n\n${action == 'cancel' ? 'Ele será retirado dos cálculos.' : 'Ele voltará a ficar pendente.'} ${entry.settled ? 'O valor realizado também será retirado do saldo.' : ''}'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Voltar')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirmar'))
                  ]));
      if (ok != true || !mounted) return;
    }
    setState(() => busy = true);
    try {
      await source.action(entry.id, action, date: date);
      if (mounted) {
        notify('Lançamento atualizado.');
        await load();
      }
    } catch (e) {
      if (mounted) notify(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = entries
        .where((e) =>
            (filter == 'ALL' || e.type == filter) &&
            (tab != 1 || (!e.settled && !e.cancelled)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: RefreshIndicator(
                      onRefresh: load,
                      child: ListView(
                          controller: scroll,
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 112),
                          children: [
                            Row(children: [
                              Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF23262B),
                                      borderRadius: BorderRadius.circular(13)),
                                  child: const Icon(Icons.timelapse_rounded,
                                      size: 25)),
                              const SizedBox(width: 12),
                              const Expanded(
                                  child: Text('kairos',
                                      style: TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -1))),
                              IconButton(
                                  tooltip: hideAmounts
                                      ? 'Mostrar valores'
                                      : 'Ocultar valores',
                                  onPressed: () => setState(
                                      () => hideAmounts = !hideAmounts),
                                  icon: Icon(hideAmounts
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined)),
                              IconButton(
                                  tooltip: 'Conexão e saldo inicial',
                                  onPressed: settings,
                                  icon: const Icon(Icons.tune_rounded))
                            ]),
                            const SizedBox(height: 28),
                            const Text('SEU DINHEIRO, COM CLAREZA',
                                style: TextStyle(
                                    color: muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text(
                                tab == 1
                                    ? 'O que vem pela frente.'
                                    : 'Seu mês, sob controle.',
                                style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.8)),
                            const SizedBox(height: 22),
                            Row(children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 17, color: muted),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                      '${months[month.month - 1]} ${month.year}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))),
                              IconButton(
                                  tooltip: 'Mês anterior',
                                  onPressed:
                                      busy ? null : () => changeMonth(-1),
                                  icon: const Icon(Icons.chevron_left)),
                              IconButton(
                                  tooltip: 'Próximo mês',
                                  onPressed: busy ? null : () => changeMonth(1),
                                  icon: const Icon(Icons.chevron_right))
                            ]),
                            if (source.demo)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(children: [
                                    const Icon(Icons.science_outlined,
                                        size: 16, color: muted),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                        child: Text(
                                            'Demonstração · dados fictícios',
                                            style: TextStyle(
                                                fontSize: 12, color: muted))),
                                    TextButton(
                                        onPressed: connect,
                                        child: const Text('Conectar'))
                                  ])),
                            if (loading)
                              const Padding(
                                  padding: EdgeInsets.all(48),
                                  child: Center(
                                      child: CircularProgressIndicator()))
                            else if (error != null)
                              panel(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.cloud_off_outlined),
                                    const SizedBox(height: 16),
                                    const Text('Não conseguimos atualizar',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    Text(error!,
                                        style: const TextStyle(color: muted)),
                                    const SizedBox(height: 16),
                                    Wrap(spacing: 8, children: [
                                      FilledButton(
                                          onPressed: load,
                                          child:
                                              const Text('Tentar novamente')),
                                      TextButton(
                                          onPressed: connect,
                                          child: const Text('Conexão'))
                                    ])
                                  ]))
                            else ...[
                              if (summary?.configured != true)
                                panel(Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Vamos começar pelo seu saldo',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 10),
                                      const Text(
                                          'Informe quanto você tinha antes dos primeiros lançamentos. A partir daí, o Kairos acompanha seu mês.',
                                          style: TextStyle(color: muted)),
                                      const SizedBox(height: 18),
                                      FilledButton(
                                          onPressed: opening,
                                          child: const Text(
                                              'Informar saldo inicial'))
                                    ]))
                              else ...[
                                balanceCard(summary!),
                                const SizedBox(height: 14),
                                Row(children: [
                                  Expanded(
                                      child: smallCard(
                                          'A receber',
                                          summary!.receivable,
                                          Icons.south_west_rounded)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: smallCard(
                                          'A pagar',
                                          summary!.payable,
                                          Icons.north_east_rounded))
                                ]),
                                const SizedBox(height: 10),
                                Text(
                                    summary!.historical
                                        ? 'Visão realizada no encerramento do mês.'
                                        : 'Pendências até o fim do mês, incluindo atrasados.',
                                    style: const TextStyle(
                                        color: muted, fontSize: 11))
                              ],
                              const SizedBox(height: 30),
                              Row(children: [
                                Expanded(
                                    child: Text(
                                        tab == 1
                                            ? 'Próximos do mês'
                                            : 'Lançamentos',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600))),
                                Text('${filtered.length} registros',
                                    style: const TextStyle(
                                        color: muted, fontSize: 12))
                              ]),
                              const SizedBox(height: 14),
                              Wrap(
                                  spacing: 8,
                                  children: [
                                    ('ALL', 'Todos'),
                                    ('INCOME', 'Receitas'),
                                    ('EXPENSE', 'Despesas')
                                  ]
                                      .map((item) => ChoiceChip(
                                          label: Text(item.$2),
                                          selected: filter == item.$1,
                                          showCheckmark: false,
                                          selectedColor:
                                              const Color(0xFFF5F7FA),
                                          labelStyle: TextStyle(
                                              color: filter == item.$1
                                                  ? const Color(0xFF101113)
                                                  : muted),
                                          onSelected: (_) =>
                                              setState(() => filter = item.$1)))
                                      .toList()),
                              const SizedBox(height: 14),
                              if (filtered.isEmpty)
                                panel(Column(children: [
                                  const Icon(Icons.edit_note_rounded,
                                      size: 36, color: muted),
                                  const SizedBox(height: 12),
                                  const Text('Um mês para organizar',
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(height: 8),
                                  const Text(
                                      'Adicione o que você espera receber e pagar. Tudo começa com uma anotação.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: muted)),
                                  const SizedBox(height: 16),
                                  TextButton(
                                      onPressed: () => edit(),
                                      child: const Text('Adicionar lançamento'))
                                ]))
                              else
                                Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF181A1D),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFF292C31))),
                                    child: Column(children: [
                                      for (var i = 0;
                                          i < filtered.length;
                                          i++) ...[
                                        entryRow(filtered[i]),
                                        if (i < filtered.length - 1)
                                          const Divider(
                                              height: 1,
                                              indent: 18,
                                              endIndent: 18,
                                              color: Color(0xFF292C31))
                                      ]
                                    ])),
                              const SizedBox(height: 24),
                              const Center(
                                  child: Text(
                                      'Organizar o presente. Projetar o futuro.',
                                      style: TextStyle(
                                          color: muted, fontSize: 11))),
                            ],
                          ]))))),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Novo lançamento',
          onPressed: loading || busy || error != null ? null : () => edit(),
          backgroundColor: const Color(0xFFF5F7FA),
          foregroundColor: const Color(0xFF101113),
          child: const Icon(Icons.add_rounded, size: 30)),
      bottomNavigationBar: NavigationBar(
          height: 72,
          backgroundColor: const Color(0xFF181A1D),
          selectedIndex: tab,
          indicatorColor: const Color(0xFF30343B),
          onDestinationSelected: (value) {
            setState(() => tab = value);
            scroll.jumpTo(0);
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Meu mês'),
            NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note_rounded),
                label: 'Próximos')
          ]),
    );
  }

  void changeMonth(int delta) {
    setState(() => month = DateTime(month.year, month.month + delta));
    load();
  }

  Widget panel(Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: const Color(0xFF181A1D),
          borderRadius: BorderRadius.circular(20)),
      child: child);
  Widget balanceCard(Overview s) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C3036), Color(0xFF1C1F23)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF454A53)),
          boxShadow: const [
            BoxShadow(color: Color(0x0CF5F7FA), blurRadius: 24)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(
                  s.historical ? 'Saldo no encerramento' : 'Saldo atual',
                  style: const TextStyle(color: muted))),
          const Icon(Icons.account_balance_wallet_outlined,
              size: 19, color: muted)
        ]),
        const SizedBox(height: 12),
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(amount(s.current),
                style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.3))),
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF44484F)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(
                  s.historical
                      ? 'Realizado até o fim do mês'
                      : 'Previsão no fim do mês',
                  style: const TextStyle(fontSize: 12, color: muted))),
          Flexible(
              child: Text(amount(s.projected),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)))
        ]),
      ]));
  Widget smallCard(String label, int value, IconData icon) => Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
          color: const Color(0xFF181A1D),
          borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 12, color: muted)),
        const SizedBox(height: 5),
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(amount(value),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 19)))
      ]));
  Widget entryRow(Entry e) => InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: busy ? null : () => detail(e),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xFF25282D),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                    e.income
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    size: 18)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(e.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration:
                              e.cancelled ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: 5),
                  Text(
                      '${shortDate(e.date)}${e.category.isEmpty ? '' : ' · ${e.category}'}',
                      style: const TextStyle(color: muted, fontSize: 11))
                ])),
            const SizedBox(width: 8),
            Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Text('${e.income ? '+' : '−'} ${amount(e.amount)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 5),
                  Text(e.label,
                      style: const TextStyle(color: muted, fontSize: 10))
                ])),
          ])));
  Future<void> detail(Entry e) async {
    final action = await showModalBottomSheet<String>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.description,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('${amount(e.amount)} · ${e.label}',
                          style: const TextStyle(color: muted)),
                      Text(
                          'Previsto: ${shortDate(e.date)}/${e.date.year}${e.settledDate == null ? '' : '\nRealizado: ${shortDate(e.settledDate!)}/${e.settledDate!.year}'}',
                          style: const TextStyle(color: muted)),
                      if (e.notes.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(e.notes)),
                      const SizedBox(height: 20),
                      if (!e.settled && !e.cancelled)
                        ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(e.income
                                ? 'Marcar como recebido'
                                : 'Marcar como pago'),
                            onTap: () => Navigator.pop(context, 'settle')),
                      ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: const Text('Editar lançamento'),
                          onTap: () => Navigator.pop(context, 'edit')),
                      if (e.settled || e.cancelled)
                        ListTile(
                            leading: const Icon(Icons.undo),
                            title: const Text('Reabrir lançamento'),
                            onTap: () => Navigator.pop(context, 'reopen')),
                      if (!e.cancelled)
                        ListTile(
                            leading: const Icon(Icons.block_outlined),
                            title: const Text('Cancelar lançamento'),
                            onTap: () => Navigator.pop(context, 'cancel')),
                    ]))));
    if (!mounted || action == null) return;
    if (action == 'edit') {
      await edit(e);
    } else {
      await act(e, action);
    }
  }

  Future<void> settings() async {
    final selected = await showModalBottomSheet<String>(
        context: context,
        useSafeArea: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const ListTile(
                  title: Text('Seu Kairos',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.w600)),
                  subtitle: Text('Organize do seu jeito.')),
              ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Conectar meus dados'),
                  subtitle: Text(source.demo
                      ? 'Você está na demonstração'
                      : 'Servidor configurado nesta sessão'),
                  onTap: () => Navigator.pop(context, 'connect')),
              ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Configurar saldo inicial'),
                  onTap: () => Navigator.pop(context, 'balance')),
              if (!source.demo)
                ListTile(
                    leading: const Icon(Icons.science_outlined),
                    title: const Text('Ver demonstração'),
                    onTap: () => Navigator.pop(context, 'demo')),
            ])));
    if (!mounted) return;
    if (selected == 'connect') await connect();
    if (selected == 'balance') await opening();
    if (selected == 'demo') {
      source.close();
      source = DemoSource();
      await load();
    }
  }
}

class ConnectionDialog extends StatefulWidget {
  final String initial;
  const ConnectionDialog({super.key, required this.initial});
  @override
  State<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  late final controller = TextEditingController(text: widget.initial);
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Conectar meus dados'),
          content: Form(
              key: form,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Endereço do servidor Kairos. Para desenvolvimento por USB, use o encaminhamento de porta descrito no README.',
                        style: TextStyle(fontSize: 13, color: muted)),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: controller,
                        decoration:
                            const InputDecoration(labelText: 'Endereço da API'),
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          final uri = Uri.tryParse(v?.trim() ?? '');
                          return uri == null ||
                                  !['http', 'https'].contains(uri.scheme) ||
                                  uri.host.isEmpty ||
                                  uri.userInfo.isNotEmpty ||
                                  uri.hasQuery ||
                                  uri.hasFragment ||
                                  (uri.path.isNotEmpty && uri.path != '/')
                              ? 'Informe http(s)://endereço:porta'
                              : null;
                        }),
                    const SizedBox(height: 10),
                    const Text(
                        'O endereço vale para esta sessão. Seus registros ficam no servidor.',
                        style: TextStyle(fontSize: 11, color: muted)),
                  ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar')),
            FilledButton(
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text('Conectar'))
          ]);
}
