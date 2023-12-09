// ignore_for_file: avoid_print

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
  List<TodoItem> foundtodos = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    foundtodos = List<TodoItem>.from(todos);
    super.initState();
  }

  Color dayBackgroundColor = const Color.fromARGB(255, 166, 106, 15);
  Color dayTextColor = const Color.fromARGB(255, 255, 181, 101);

  Color nightBackgroundColor = Colors.black;
  Color nightTextColor = Colors.white;

  final ThemeData kDayTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  );

  final ThemeData kNightTheme = ThemeData(
    brightness: Brightness.dark,
    hintColor: Colors.green,
  );

  bool isNightMode = false;

  void toggleTheme() {
    setState(() {
      isNightMode = !isNightMode;
    });
  }

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

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          searcher(value);
        },
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(
              maxHeight: 20,
              minWidth: 25,
            ),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey)),
      ),
    );
  }

  void searcher(String searchingword) {
    List<TodoItem> results = [];
    if (searchingword.isEmpty) {
      results = List<TodoItem>.from(todos);
    } else {
      results = todos
          .where((todo) =>
              todo.title.toLowerCase().contains(searchingword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundtodos = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 95, 75),
      appBar: AppBar(
        elevation: 0,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Icon(
            Icons.menu,
            size: 30,
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset('assets/images/IMan.jpg'),
            ),
          )
        ]),
      ),
      body: Column(
        children: [
          const Text('All of my To-Dos',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 246, 194, 135))),
          searchBox(),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(todos[index].title),
                    background: Container(
                      color: const Color.fromARGB(255, 88, 52, 2),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsetsDirectional.all(20.0),
                      child: const Icon(Icons.delete,
                          color: Color.fromARGB(255, 46, 25, 12)),
                    ),
                    onDismissed: (direction) {
                      deleteTask(index);
                      print('Task Deleted');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: CheckboxListTile(
                        title: Text(
                          todos[index].title,
                          style: TextStyle(
                            decoration: todos[index].isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        value: todos[index].isDone,
                        onChanged: (bool? value) {
                          setState(() {
                            todos[index].isDone = value ?? false;
                          });
                          // ignore: unused_label
                          onTap:
                          () {
                            print('Clicked on a Todo task');
                          };
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
