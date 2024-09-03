// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:NIMAS/pages/first_page.dart';
import 'package:NIMAS/pages/home_page.dart';
import 'package:NIMAS/pages/profile_page.dart';
import 'package:NIMAS/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
      routes: {
        '/firstpage': (context) => FirstPage(),
        '/homepage': (context) => HomePage(),
        '/settingspage': (context) => SettingsPage(),
        '/profilepage': (context) => ProfilePage()
      },
    );
  }
}

