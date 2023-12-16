// ignore_for_file: unused_import, camel_case_types

import 'package:hive/hive.dart';

part 'todos_list.g.dart';

@HiveType(typeId: 1)
class todoslist {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  late String priority;

  @HiveField(4)
  late String tag;

  todoslist({
    required this.title,
    required this.isCompleted,
    this.dueDate,
    //this.priority = 'medium',
    //this.tag = 'personal'
  });
}
