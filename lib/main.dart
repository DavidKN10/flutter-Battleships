import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Battleships',
    home: LoginScreen(),
  ));
}
