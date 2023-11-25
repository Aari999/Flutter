import 'package:flutter/material.dart';

class TodoItem {
  String title;
  bool isDone;
  TodoItem({required this.title, this.isDone = false});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: prefer_final_fields
  List<TodoItem> todos = [];

  void addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTodo = "";
        return AlertDialog(
          title: const Text('Add Z Task'),
          content: TextField(
            onChanged: (String value) {
              newTodo = value;
            },
            decoration: const InputDecoration(
              labelText: 'Enter',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  todos.add(TodoItem(title: newTodo));
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do Lists'),
        backgroundColor: Colors.brown,
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(todos[index].title),
            background: Container(
              color: const Color.fromARGB(255, 255, 212, 153),
              alignment: Alignment.centerRight,
              padding: const EdgeInsetsDirectional.all(8.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              deleteTask(index);
            },
            child: CheckboxListTile(
              title: Text(todos[index].title),
              value: todos[index].isDone,
              onChanged: (bool? value) {
                setState(() {
                  todos[index].isDone = value ?? false;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
