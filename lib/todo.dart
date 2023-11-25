import 'package:flutter/material.dart';

void main() {
  runApp(const MyTodoApp());
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Simple Todo App',
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  Todolistestate createState() => Todolistestate();
}

class Todolistestate extends State<TodoList> {
  List<String> todos = [];

  TextEditingController tec = TextEditingController();

  void _addTodo() {
    setState(() {
      todos.add(tec.text);
      tec.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: tec,
              decoration: InputDecoration(
                labelText: 'Enter todo',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(todos[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
