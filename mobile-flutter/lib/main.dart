import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'finance.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  runApp(const KairosApp());
}

class KairosApp extends StatelessWidget {
  final FinanceSource? source;
  const KairosApp({super.key, this.source});
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Kairos',
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101113),
        colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF5F7FA),
            onPrimary: Color(0xFF101113),
            secondary: Color(0xFFF5F7FA),
            onSecondary: Color(0xFF101113),
            secondaryContainer: Color(0xFFF5F7FA),
            onSecondaryContainer: Color(0xFF101113),
            tertiary: Color(0xFFF5F7FA),
            primaryContainer: Color(0xFF30343B),
            onPrimaryContainer: Color(0xFFF5F7FA),
            surface: Color(0xFF181A1D),
            onSurface: Color(0xFFF5F7FA),
            outline: Color(0xFF30343B)),
        textTheme:
            const TextTheme(bodyMedium: TextStyle(fontSize: 14, height: 1.45)),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF202328),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none)),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)))),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color(0xFF181A1D), showDragHandle: true),
      ),
      home: HomePage(source: source));
}
