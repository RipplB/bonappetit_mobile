import 'package:flutter/material.dart';
import 'loginpage.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Widget login = LoginPage();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ételrendelés',
      initialRoute: '/',
      routes: {
        '/': (context) => login
      },
    );
  }
}