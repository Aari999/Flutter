import 'package:flutter/material.dart';
import 'package:todo/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'To-Do List',
      home: MyHomePage(),
    );
  }
}
