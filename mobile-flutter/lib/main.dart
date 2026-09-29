import 'package:flutter/material.dart';

void main() {
  runApp(const KairosApp());
}

class KairosApp extends StatelessWidget {
  const KairosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kairos',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const KairosHomePage(),
    );
  }
}

class KairosHomePage extends StatelessWidget {
  const KairosHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kairos')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu controle financeiro, no momento certo.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('A base mobile está pronta para consumir a API do Kairos.'),
          ],
        ),
      ),
    );
  }
}
