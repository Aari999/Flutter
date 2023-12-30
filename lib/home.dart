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
  DateTime dueDate;
  Priority? priority;
  Tag? tag;
  bool isDone;

  TodoItemdb({
    required this.title,
    required this.dueDate,
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabControlling;
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
    return [];
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
    tabControlling = TabController(length: 4, vsync: this);
    tabControlling.addListener(_handleTabSelection);
    getSavedTodoItems().then((retrievedItems) {
      setState(() {
        filteredTodos = retrievedItems;
        refreshTodos();
      });
    });
  }

  @override
  void dispose() {
    tabControlling.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      if (tabControlling.indexIsChanging) {
        if (tabControlling.index == 0) {
          filterTodosWithOption(FilterOptions.all);
        } else if (tabControlling.index == 1) {
          filterTodosWithOption(FilterOptions.byPriority);
        } else if (tabControlling.index == 2) {
          filterTodosWithOption(FilterOptions.byTag);
        } else if (tabControlling.index == 3) {
          filterTodosWithOption(FilterOptions.byDate);
        }
      }
    });
  }

  Priority selectedPriority = Priority.high;
  Tag selectedTag = Tag.personal;

 // get index => null;

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
        'dueDate': item.dueDate.toIso8601String(),
        'index': item.index,
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

      if (index >= 0 && index <= todoList.length) {
        todoList.removeAt(index);
        String updatedSerialized = json.encode(todoList);
        await prefs.setString('todoItems', updatedSerialized);
      }
    }
  }

  void filterTodosWithOption(FilterOptions option,
      {Tag? selectedTag, Priority? selectedPriority}) {
    setState(() {
      if (option == FilterOptions.all) {
        filteredTodos = todoList;
      } else if (option == FilterOptions.byDate) {
        filteredTodos = todoList
            .where((todo) =>
                todo.dueDate != null && todo.dueDate.isAfter(DateTime.now()))
            .toList();
      } else if (option == FilterOptions.byPriority) {
        if (selectedPriority != null) {
          filteredTodos = todoList
              .where((todo) => todo.priority == selectedPriority)
              .toList();
        } else {
          filteredTodos =
              todoList.where((todo) => todo.priority == Priority.high).toList();
        }
      } else if (option == FilterOptions.byTag) {
        if (selectedTag != null) {
          filteredTodos =
              todoList.where((todo) => todo.tag == selectedTag).toList();
        } else {
          filteredTodos =
              todoList.where((todo) => todo.tag == Tag.work).toList();
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
                    todoList.dueDate.isBefore(dueDate))) &&
            (priority == null || todoList.priority == priority) &&
            (tag == null || todoList.tag == tag);
      }).toList();
    });
  }

  void editTask(BuildContext context, TodoItemdb todoItem) async {
    TextEditingController titleController =
        TextEditingController(text: todoItem.title);
    TextEditingController dueDateController =
        TextEditingController(text: todoItem.dueDate.toString());
    TextEditingController priorityController =
        TextEditingController(text: todoItem.priority?.toString() ?? '');
    TextEditingController tagController =
        TextEditingController(text: todoItem.tag?.toString() ?? '');

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
                  setState(() => todoItem.title = newTitle),
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: dueDateController,
              onChanged: (newDueDate) {
                setState(() {
                  if (newDueDate.isNotEmpty) {
                    todoItem.dueDate = DateTime.parse(newDueDate);
                  } else {
                    todoItem.dueDate = todoItem.dueDate;
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
                    todoItem.priority = parsePrio(newPriority);
                  } else {
                    todoItem.priority = parsePrio(todoItem.priority! as String);
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
                      todoItem.tag = parseTag(newTag);
                    } else {
                      todoItem.tag = parseTag(todoItem.tag! as String);
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
                todoItem.title = titleController.text;
                dueDate:
                todoItem.dueDate = DateTime.parse(dueDateController.text);
                priority:
                todoItem.priority = parsePrio(priorityController.text);
                tag:
                todoItem.tag = parseTag(tagController.text);
                saveTodoItems(todoList);
                saveTodoItems(filteredTodos);
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
                DateTime currentDate = DateTime.now();
                DateTime? pickedDate;
                do {
                  pickedDate = await showDatePicker(
                    context: context,
                    initialDate: currentValue ?? currentDate,
                    firstDate: currentDate,
                    lastDate: DateTime(2100),
                  );
                } while (
                    pickedDate == null || pickedDate.isBefore(currentDate));
                return pickedDate;
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
                if (title.isNotEmpty && dueDate != null) {
                  DateTime currentDate = DateTime.now();
                  if (dueDate!.isAfter(currentDate)) {
                    DateTime selectedDueDate = dueDate ?? currentDate;
                    TodoItemdb newItem = TodoItemdb(
                      title: title,
                      dueDate: selectedDueDate,
                      priority: priority,
                      tag: tag,
                    );
                    todoList.add(newItem);
                    saveTodoItems(todoList);
                    setState(() {
                      filteredTodos = todoList;
                      Navigator.pop(context);
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Invalid Due Date'),
                        content: const Text(
                            'Please select a due date after the current date.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                }
              }),
        ],
      ),
    );
    dueDateController.clear();
    priorityController.clear();
    tagController.clear();
  }

  void completeTask(int index) {
    if (index >= 0 && index < todoList.length) {
      setState(() {
        todoList[index].isDone = !todoList[index].isDone;
        filteredTodos = List.from(todoList);
      });
    }
  }

  void deleteTask(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
            'Are you sure you want to delete ${filteredTodos.isNotEmpty ? filteredTodos[index].title : ''}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              setState(() {
                if (filteredTodos.isNotEmpty &&
                    index >= 0 &&
                    index < filteredTodos.length) {
                  String taskTitle = filteredTodos[index].title;
                  filteredTodos.removeAt(index);
                  saveTodoItems(filteredTodos);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted task: $taskTitle'),
                    ),
                  );
                }
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildTodoItem(int index, TodoItemdb todo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: Checkbox(
                value: todo.isDone,
                onChanged: (value) {
                  setState(() {
                    todo.isDone = value!;
                    todoList[todoList.indexOf(todo)] = todo;
                    filteredTodos = List.from(todoList);
                  });
                }),
            title: Text(todo.title),
            subtitle: Text(
              ' ${todo.priorityText} - ${todo.tagText}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => editTask(context, todo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteTask(index);
                  },
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
            const SizedBox(width: 20, height: 8),
            const Text(
              'Todo App',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
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
                      image: AssetImage('assets/taskpic.jpeg'),
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
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => filterTodosWithOption(FilterOptions.all),
                  child: const Text('All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tabControlling.index = 1;
                      filterTodosWithOption(
                        FilterOptions.byPriority,
                        selectedTag: selectedTag,
                      );
                    });
                  },
                  child: const Text('Priority'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tabControlling.index = 2;
                      filterTodosWithOption(
                        FilterOptions.byTag,
                        selectedPriority: selectedPriority,
                      );
                    });
                  },
                  child: const Text('Tag'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tabControlling.index = 3;
                      filterTodosWithOption(
                        FilterOptions.byDate,
                        selectedTag: selectedTag,
                      );
                    });
                  },
                  child: const Text('Due Date'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) =>
                    buildTodoItem(index, filteredTodos[index]),
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
