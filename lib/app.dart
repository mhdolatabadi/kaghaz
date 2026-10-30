import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'features/library/library_screen.dart';

class KaghazApp extends StatelessWidget {
  const KaghazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کاغذ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const LibraryScreen(),
    );
  }
}
