// ignore_for_file: sort_child_properties_last, library_private_types_in_public_api, duplicate_import, avoid_print, constant_identifier_names, unused_import, non_constant_identifier_names, unused_element, unused_label, unnecessary_null_comparison, unused_local_variable, body_might_complete_normally_nullable, prefer_for_elements_to_map_fromiterable, use_build_context_synchronously, unnecessary_import

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todo/data/database.dart';
import 'package:todo/filter.dart';
import 'package:todo/todos_list.dart';
import 'filter.dart';
import 'package:todo/main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<todoslist> tasks = [];

  final mybox = Hive.box('Todobox');

  List<TodoItemdb> todos = [];
  TextEditingController searchController = TextEditingController();
  List<TodoItemdb> filteredTodos = [];
  TextEditingController dueDateController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  TodoItemdb tdb = TodoItemdb(title: '');

  Color currentColor = const Color.fromARGB(255, 148, 207, 255);
  Color sectionColor = const Color.fromARGB(255, 148, 207, 255);

  @override
  void initState() {
    super.initState();
    tdb.openTodoBox();
    filteredTodos = todos;
  }

  Priority selectedPriority = Priority.high;
  Tag selectedTag = Tag.personal;

  get index => null;

  void updateSectionColor(Color newColor) {
    setState(() {
      sectionColor = newColor;
    });
  }

  void filterTodosWithOption(FilterOptions option, {Tag? selectedTag}) {
    setState(() {
      if (option == FilterOptions.all) {
        filteredTodos = todos;
      } else if (option == FilterOptions.byDate) {
        filteredTodos = todos
            .where((todo) =>
                todo.dueDate != null && todo.dueDate!.isAfter(DateTime.now()))
            .toList();
      } else if (option == FilterOptions.byPriority) {
        filteredTodos =
            todos.where((todo) => todo.priority == selectedPriority).toList();
      } else if (option == FilterOptions.byTag) {
        if (selectedTag != null) {
          filteredTodos =
              todos.where((todo) => todo.tag == selectedTag).toList();
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
      filteredTodos = todos.where((todo) {
        final lowerCaseSearch = search.toLowerCase();
        final lowerCaseTitle = todo.title.toLowerCase();

        return lowerCaseTitle.contains(lowerCaseSearch) &&
            (dueDate == null ||
                (todo.dueDate != null && todo.dueDate!.isBefore(dueDate))) &&
            (priority == null || todo.priority == priority) &&
            (tag == null || todo.tag == tag);
      }).toList();
    });
  }

  void editTask(BuildContext context, TodoItemdb todo) async {
    TextEditingController titleController =
        TextEditingController(text: todo.title);
    TextEditingController dueDateController =
        TextEditingController(text: todo.dueDate?.toString() ?? '');
    TextEditingController priorityController =
        TextEditingController(text: todo.priority?.toString() ?? '');
    TextEditingController tagController =
        TextEditingController(text: todo.tag?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              onChanged: (newTitle) => setState(() => todo.title = newTitle),
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: dueDateController,
              onChanged: (newDueDate) {
                setState(() {
                  if (newDueDate.isNotEmpty) {
                    todo.dueDate = DateTime.parse(newDueDate);
                  } else {
                    todo.dueDate = todo.dueDate;
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
                    todo.priority = parsePrio(newPriority);
                  } else {
                    todo.priority = todo.priority!;
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
                      todo.tag = parseTag(newTag);
                    } else {
                      todo.tag = todo.tag!;
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
                todo.title = titleController.text;
                todo.dueDate = DateTime.parse(dueDateController.text);
                todo.priority = parsePrio(priorityController.text);
                todo.tag = parseTag(tagController.text);
                tdb.updatingdb();
                Navigator.pop(context);
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
            onPressed: () {
              if (title.isNotEmpty) {
                setState(() {
                  todos.add(TodoItemdb(
                      title: title,
                      dueDate: dueDate,
                      priority: priority,
                      tag: tag));
                  tdb.updatingdb();
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
    setState(() => todos[index].isDone = !todos[index].isDone);
    tdb.updatingdb();
  }

  void deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete ${todos[index].title}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              setState(() => todos.removeAt(index));
              tdb.updatingdb();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildTodoItem(TodoItemdb todo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (value) => completeTask(todos.indexOf(todo)),
            ),
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
                  onPressed: () => deleteTask(todos.indexOf(todo)),
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
            // Title widget or text
            const SizedBox(
                width: 20), // Optional spacing between title and image
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
