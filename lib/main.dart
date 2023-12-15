// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:todo/home.dart';
import 'package:todo/filter.dart';

// ignore: prefer_const_constructors
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isNightMode = false;

  final ThemeData kDayTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.brown,
  );

  final ThemeData kNightTheme = ThemeData(
    brightness: Brightness.dark,
    hintColor: const Color.fromARGB(255, 126, 162, 128),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isNightMode ? kNightTheme : kDayTheme,
      color: const Color.fromARGB(255, 184, 111, 197),
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      // ignore: prefer_const_constructors
      home: MyHomePage(),
    );
  }
}
