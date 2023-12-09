import 'package:flutter/material.dart';
import 'package:todo/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeData kDayTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  );

  final ThemeData kNightTheme = ThemeData(
    brightness: Brightness.dark,
    hintColor: Colors.green,
  );

  bool isNightMode = false;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //theme: isNightMode? kNightTheme : kDayTheme,
      color: Color.fromARGB(255, 184, 111, 197),
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      home: MyHomePage(),
    );
  }
}
