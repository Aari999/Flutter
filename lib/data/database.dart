import 'package:hive_flutter/hive_flutter.dart';

enum Priority { high, medium, low }

Priority parsePrio(String constvalue) {
  switch (constvalue.toLowerCase()) {
    case 'low':
      return Priority.low;
    case 'medium':
      return Priority.medium;
    case 'high':
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
    case 'work':
      return Tag.work;
    case 'personal':
      return Tag.personal;
    case 'school':
      return Tag.school;
    case 'home':
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
    //required this.index,
    this.dueDate,
    this.priority = Priority.medium,
    this.tag = Tag.personal,
    this.isDone = false,
    this.index = 0,
  });

  String get priorityText => priority.toString().split('.').last.toUpperCase();
  String get tagText => tag.toString().split('.').last.toUpperCase();

  List<TodoItemdb> todos = [];

  final mybox = Hive.box('Todobox');

  void openTodoBox() async {
    await Hive.initFlutter();
    loadTodos();
  }

  void loadTodos() {
    todos = mybox.get("TODOS");
  }

  void updatingdb() {
    mybox.put("TODOS", todos);
  }
}
