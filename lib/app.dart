import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/notebooks/notebooks_screen.dart';

class KaghazApp extends StatelessWidget {
  const KaghazApp({super.key});

  static const _seed = Color(0xFF3D5A80);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کاغذ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorSchemeSeed: _seed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: _seed,
        brightness: Brightness.dark,
      ),
      home: const NotebooksScreen(),
    );
  }
}
