// ignore_for_file: unused_import, unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:todo/home.dart';
import 'package:todo/filter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/todos_list.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(todoslistAdapter());
  await Hive.openBox<todoslist>('todos');
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
    hintColor: const Color.fromARGB(255, 126, 162, 128),
  );

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

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
