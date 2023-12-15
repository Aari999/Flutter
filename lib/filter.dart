// ignore_for_file: non_constant_identifier_names, sort_child_properties_last, unused_local_variable, body_might_complete_normally_nullable

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(DateTime?, Priority?, Tag?) onFilter;

  const FilterBottomSheet({Key? key, required this.onFilter}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

enum Priority { high, medium, low }

enum Tag { home, work, school, personal }

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? dueDate;
  Priority? priority;
  Tag? tag;

  void clearFilter() {
    setState(() {
      dueDate = null;
      priority = null;
      tag = null;
    });
  }

  void applyFilter() {
    widget.onFilter(dueDate, priority, tag);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Due Date:', style: TextStyle(fontSize: 18)),
            DateTimeField(
                controller: TextEditingController(),
                decoration: const InputDecoration(labelText: 'Select Date'),
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
                  // return null;
                }),
            const SizedBox(height: 15),
            const Text('Priority:', style: TextStyle(fontSize: 18)),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Select Priority'),
              value: priority,
              items: Priority.values
                  .map((p) => DropdownMenuItem(
                        child: Text(p.toString().split('.').last.toUpperCase()),
                        value: p,
                      ))
                  .toList(),
              onChanged: (value) => setState(() => priority = value),
            ),
            const SizedBox(height: 15),
            const Text('Tag:', style: TextStyle(fontSize: 18)),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Select Tag'),
              value: tag,
              items: Tag.values
                  .map((t) => DropdownMenuItem(
                        child: Text(t.toString().split('.').last.toUpperCase()),
                        value: t,
                      ))
                  .toList(),
              onChanged: (value) => setState(() => tag = value),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: clearFilter,
                  child: const Text('Clear Filter'),
                ),
                ElevatedButton(
                  onPressed: applyFilter,
                  child: const Text('Apply Filter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
