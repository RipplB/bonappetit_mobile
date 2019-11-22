import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'menu.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Widget login = LoginPage();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ételrendelés',
      initialRoute: '/',
      routes: {
        '/': (context) => login,
        'menu': (context) => Menu()
      },
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale("hu")],
    );
  }
}