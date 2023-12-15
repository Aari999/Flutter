// ignore_for_file: sort_child_properties_last, library_private_types_in_public_api, duplicate_import, avoid_print

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:todo/filter.dart';
import 'filter.dart';

enum Priority { high, medium, low }

enum Tag { home, work, school, personal }

class TodoItem {
  String title;
  int index;
  DateTime? dueDate;
  Priority? priority;
  Tag? tag;
  bool isDone;

  TodoItem({
    required this.title,
    //required this.index,
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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TodoItem> todos = [];
  TextEditingController searchController = TextEditingController();
  List<TodoItem> filteredTodos = [];
  TextEditingController dueDateController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  Color appBarColor = const Color.fromARGB(255, 145, 249, 255);

  get index => null;

  @override
  void initState() {
    filteredTodos = todos;
    super.initState();
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
                return pickedDate ?? DateTime.now();
              },
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Priority'),
              value: priority,
              items: Priority.values
                  .map((p) => DropdownMenuItem(
                        child: Text(p.toString().split('.').last.toUpperCase()),
                        value: p,
                      ))
                  .toList(),
              onChanged: (value) => setState(() => priority = value!),
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Tag'),
              value: tag,
              items: Tag.values
                  .map((t) => DropdownMenuItem(
                        child: Text(t.toString().split('.').last.toUpperCase()),
                        value: t,
                      ))
                  .toList(),
              onChanged: (value) => setState(() => tag = value!),
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
                setState(() => todos.add(TodoItem(
                    title: title,
                    dueDate: dueDate,
                    priority: priority,
                    tag: tag)));
                Navigator.pop(context);
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildTodoItem(TodoItem todo) {
    return ListTile(
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
    );
  }

  void editTask(BuildContext context, TodoItem todo) async {
    TextEditingController textController =
        TextEditingController(text: todo.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          // initialValue: todos[index].title,
          onChanged: (newTitle) =>
              setState(() => todos[index].title = newTitle),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              setState(() => todos[index] = TodoItem(
                  title: textController.text,
                  isDone: todos[index].isDone,
                  index: todos[index].index));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => {
              setState(() {
                appBarColor = const Color.fromARGB(255, 179, 7, 241);
              })
            },
          ),
          Stack(children: [
            ClipRRect(
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
            Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                )),
          ]),
        ]),
      ),
      body: Column(
        children: [
          const Text('All Todos',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => filterTodos(value, null, null, null),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Filter'),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => FilterBottomSheet(
                      onFilter: (dueDate, priority, tag) => filterTodos(
                        searchController.text,
                        dueDate,
                        priority as Priority?,
                        tag as Tag?,
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
