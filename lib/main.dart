// ignore_for_file: unused_import, unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:todo/home.dart';
import 'package:todo/filter.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  var box = await Hive.openBox('Todobox');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    hintColor: Color.fromARGB(255, 175, 255, 179),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isNightMode ? kNightTheme : kDayTheme,
      color: const Color.fromARGB(255, 184, 111, 197),
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      home: MyHomePage(),
    );
  }
}
