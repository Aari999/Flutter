// ignore_for_file: sort_child_properties_last, library_private_types_in_public_api, duplicate_import, avoid_print, constant_identifier_names, unused_import, non_constant_identifier_names, unused_element, unused_label, unnecessary_null_comparison, unused_local_variable, body_might_complete_normally_nullable, prefer_for_elements_to_map_fromiterable, use_build_context_synchronously, unnecessary_import, unused_field

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/data/database.dart';
import 'package:todo/filter.dart';
import 'filter.dart';
import 'package:todo/main.dart';

enum Priority { high, medium, low }

Priority parsePrio(String constvalue) {
  switch (constvalue.toLowerCase()) {
    case 'low' || 'priority.low':
      return Priority.low;
    case 'medium' || 'priority.medium':
      return Priority.medium;
    case 'high' || 'priority.high':
      return Priority.high;
    default:
      throw ArgumentError('Invalid priority value: $constvalue');
  }
}

enum Tag {
  home,
  work,
  school,
  personal,
}

Tag parseTag(String value) {
  switch (value.toLowerCase()) {
    case 'work' || 'tag.work':
      return Tag.work;
    case 'personal' || 'tag.personal':
      return Tag.personal;
    case 'school' || 'tag.school':
      return Tag.school;
    case 'home' || 'tag.home':
      return Tag.home;
    default:
      throw ArgumentError('Invalid tag value: $value');
  }
}

class TodoItemdb {
  String title;
  int index;
  DateTime? dueDate;
  Priority? priority;
  Tag? tag;
  bool isDone;

  TodoItemdb({
    required this.title,
    this.dueDate,
    this.priority = Priority.medium,
    this.tag = Tag.personal,
    this.isDone = false,
    this.index = 0,
  });
  String get priorityText => priority.toString().split('.').last.toUpperCase();
  String get tagText => tag.toString().split('.').last.toUpperCase();
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //List<TodoItemdb> todos = [];
  List<TodoItemdb> todoList = [];
  List<TodoItemdb> filteredTodos = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  Color currentColor = const Color.fromARGB(255, 148, 207, 255);
  Color sectionColor = const Color.fromARGB(255, 148, 207, 255);

  Future<List<TodoItemdb>> getSavedTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serialized = prefs.getString('todoItems');
    if (serialized != null) {
      List<dynamic> decoded = json.decode(serialized);
      return decoded.map((item) {
        return TodoItemdb(
          title: item['title'],
          dueDate: DateTime.parse(item['dueDate']),
          priority: parsePrio(item['priority']),
          tag: parseTag(item['tag']),
        );
      }).toList();
    }
    return []; // Return empty list if there aint no todos
  }

  Future<void> refreshTodos() async {
    List<TodoItemdb> retrievedItems = await getSavedTodoItems();
    setState(() {
      filteredTodos = retrievedItems;
    });
  }

  @override
  void initState() {
    super.initState();
    getSavedTodoItems().then((retrievedItems) {
      setState(() {
        filteredTodos = retrievedItems;
        refreshTodos();
      });
    });
  }

  Priority selectedPriority = Priority.high;
  Tag selectedTag = Tag.personal;

  get index => null;

  void updateSectionColor(Color newColor) {
    setState(() {
      sectionColor = newColor;
    });
  }

  void saveTodoItems(List<TodoItemdb> todoList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> serializedList = todoList.map((item) {
      return {
        'title': item.title,
        'dueDate': item.dueDate?.toIso8601String(),
        'priority': item.priority.toString(),
        'tag': item.tag.toString(),
        'isDone': item.isDone,
      };
    }).toList();

    String serialized = json.encode(serializedList);
    await prefs.setString('todoItems', serialized);
  }

  Future deleteTodoItemfrommemory(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serialized = prefs.getString('todoItems');

    if (serialized != null) {
      List<dynamic> decoded = json.decode(serialized);
      List<Map<String, dynamic>> todoList =
          decoded.cast<Map<String, dynamic>>();

      if (index >= 0 && index < todoList.length) {
        todoList.removeAt(index);
        String updatedSerialized = json.encode(todoList);
        await prefs.setString('todoItems', updatedSerialized);
      }
    }
  }

  void filterTodosWithOption(FilterOptions option, {Tag? selectedTag}) {
    setState(() {
      if (option == FilterOptions.all) {
        filteredTodos = todoList;
      } else if (option == FilterOptions.byDate) {
        filteredTodos = todoList
            .where((todoList) =>
                todoList.dueDate != null &&
                todoList.dueDate!.isAfter(DateTime.now()))
            .toList();
      } else if (option == FilterOptions.byPriority) {
        filteredTodos = todoList
            .where((todoList) => todoList.priority == selectedPriority)
            .toList();
      } else if (option == FilterOptions.byTag) {
        if (selectedTag != null) {
          filteredTodos = todoList
              .where((todoList) => todoList.tag == selectedTag)
              .toList();
        }
      }
    });
  }

  bool isSearchOpen = false;
  void toggleSearch() {
    setState(() {
      isSearchOpen = !isSearchOpen;
    });
  }

  void filterTodos(
      String search, DateTime? dueDate, Priority? priority, Tag? tag) {
    print(
        'Filtering with search: $search, dueDate: $dueDate, priority: $priority, tag: $tag');
    setState(() {
      filteredTodos = todoList.where((todoList) {
        final lowerCaseSearch = search.toLowerCase();
        final lowerCaseTitle = todoList.title.toLowerCase();
        return lowerCaseTitle.contains(lowerCaseSearch) &&
            (dueDate == null ||
                (todoList.dueDate != null &&
                    todoList.dueDate!.isBefore(dueDate))) &&
            (priority == null || todoList.priority == priority) &&
            (tag == null || todoList.tag == tag);
      }).toList();
    });
  }

  void editTask(BuildContext context, todoList) async {
    TextEditingController titleController =
        TextEditingController(text: todoList.title);
    TextEditingController dueDateController =
        TextEditingController(text: todoList.dueDate?.toString() ?? '');
    TextEditingController priorityController =
        TextEditingController(text: todoList.priority?.toString() ?? '');
    TextEditingController tagController =
        TextEditingController(text: todoList.tag?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              onChanged: (newTitle) =>
                  setState(() => todoList.title = newTitle),
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: dueDateController,
              onChanged: (newDueDate) {
                setState(() {
                  if (newDueDate.isNotEmpty) {
                    todoList.dueDate = DateTime.parse(newDueDate);
                  } else {
                    todoList.dueDate = todoList.dueDate;
                  }
                });
              },
              decoration: const InputDecoration(labelText: 'Due Date'),
            ),
            TextField(
              controller: priorityController,
              onChanged: (newPriority) {
                setState(() {
                  if (newPriority.isNotEmpty) {
                    todoList.priority = parsePrio(newPriority);
                  } else {
                    todoList.priority = parsePrio(todoList.priority! as String);
                  }
                });
              },
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            TextField(
                controller: tagController,
                onChanged: (newTag) {
                  setState(() {
                    if (newTag.isNotEmpty) {
                      todoList.tag = parseTag(newTag);
                    } else {
                      todoList.tag = parseTag(todoList.tag! as String);
                    }
                  });
                },
                decoration: const InputDecoration(labelText: 'Tag')),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
                title:
                todoList.title = titleController.text;
                dueDate:
                todoList.dueDate = DateTime.parse(dueDateController.text);
                priority:
                todoList.priority = parsePrio(priorityController.text);
                tag:
                todoList.tag = parseTag(tagController.text);
                // isDone: false,
                saveTodoItems(todoList);
              });
            },
          ),
        ],
      ),
    );
  }

  void addTask() async {
    String title = '';
    DateTime? dueDate;
    Priority priority = Priority.medium;
    Tag tag = Tag.personal;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) => setState(() => title = value),
            ),
            DateTimeField(
              controller: dueDateController,
              decoration: const InputDecoration(labelText: 'Due Date'),
              format: DateFormat('yyyy-MM-dd'),
              onChanged: (value) => setState(() => dueDate = value),
              onShowPicker:
                  (BuildContext context, DateTime? currentValue) async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentValue ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                //kessete and kalssete
                return pickedDate ?? DateTime.now();
              },
            ),
            DropdownButtonFormField<Priority>(
              decoration: const InputDecoration(labelText: 'Priority'),
              value: priority,
              items: Priority.values
                  .map((p) => DropdownMenuItem(
                        child: Text(
                            p.toString().split('.').last[0].toUpperCase() +
                                p
                                    .toString()
                                    .split('.')
                                    .last
                                    .substring(1)
                                    .toLowerCase()),
                        value: p,
                      ))
                  .toList(),
              onChanged: (Priority? value) {
                setState(() {
                  priority = value!;
                });
              },
            ),
            DropdownButtonFormField<Tag>(
              decoration: const InputDecoration(labelText: 'Tag'),
              value: tag,
              items: Tag.values
                  .map((t) => DropdownMenuItem(
                        child: Text(
                            t.toString().split('.').last[0].toUpperCase() +
                                t
                                    .toString()
                                    .split('.')
                                    .last
                                    .substring(1)
                                    .toLowerCase()),
                        value: t,
                      ))
                  .toList(),
              onChanged: (Tag? value) {
                setState(() {
                  tag = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              if (title.isNotEmpty) {
                TodoItemdb newItem = TodoItemdb(
                  title: title,
                  dueDate: dueDate,
                  priority: priority,
                  tag: tag,
                  // isDone: false,
                );
                todoList.add(newItem);
                saveTodoItems(todoList);
                setState(() {
                  filteredTodos = todoList;
                  Navigator.pop(context);
                });
              }
            },
          ),
        ],
      ),
    );
    dueDateController.clear();
    priorityController.clear();
    tagController.clear();
  }

  void completeTask(int index) {
    setState(() {
      //todos[index].isDone = !todos[index].isDone;
      todoList[index].isDone = !todoList[index].isDone;
      filteredTodos = List.from(todoList);
      //filteredTodos = List.from(todoList.where((todoList) => !todoList.isDone));
    });
  }

  void deleteTask(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content:
            Text('Are you sure you want to delete ${todoList[index].title}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              setState(() {
                //todos.removeAt(index);
                todoList.removeAt(index);
                deleteTodoItemfrommemory(index);
              });
              saveTodoItems(todoList);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildTodoItem(todoList) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: Checkbox(
              value: todoList.isDone,
              onChanged: (value) => completeTask(todoList.indexOf(todoList)),
            ),
            title: Text(todoList.title),
            subtitle: Text(
              ' ${todoList.priorityText} - ${todoList.tagText}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => editTask(context, todoList),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteTask(todoList.indexOf(todoList)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: currentColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey,
                    child: const Image(
                      image: AssetImage('assets/IMan.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: currentColor,
              ),
              child: const Text('Menu'),
            ),
            ListTile(
              title: const Text('Change Theme'),
              onTap: () {
                setState(() {
                  if (currentColor ==
                      const Color.fromARGB(255, 148, 207, 255)) {
                    currentColor = const Color.fromARGB(255, 200, 47, 255);
                  } else {
                    currentColor = const Color.fromARGB(255, 101, 181, 247);
                    updateSectionColor(const Color.fromARGB(255, 200, 47, 255));
                  }
                });
                Navigator.pop(context);
              },
            ),
            // maybe lela neger ke color wichi
          ],
        ),
      ),
      body: Container(
        color: sectionColor,
        child: Column(
          children: [
            const Text(
              'All Todos',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) =>
                            filterTodos(value, null, null, null),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FilterOptions>(
                        onChanged: (value) {
                          if (value != null) {
                            filterTodosWithOption(value);
                          }
                        },
                        items: FilterOptions.values.map((option) {
                          return DropdownMenuItem<FilterOptions>(
                            value: option,
                            child: Row(
                              children: [
                                Text(option.title),
                                const SizedBox(width: 8.0),
                                Icon(option.icon),
                              ],
                            ),
                          );
                        }).toList(),
                        icon: const Icon(Icons.filter_list),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        isExpanded: true,
                        hint: const Text('Filter',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) =>
                    buildTodoItem(filteredTodos[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
