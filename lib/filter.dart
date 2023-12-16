// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';

enum FilterOptions {
  byDate,
  byPriority,
  byTag,
  all,
}

extension FilterOptionsExtension on FilterOptions {
  String get title {
    switch (this) {
      case FilterOptions.all:
        return 'All';
      case FilterOptions.byDate:
        return 'By Date';
      case FilterOptions.byPriority:
        return 'By Priority';
      case FilterOptions.byTag:
        return 'By Tag';
      default:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case FilterOptions.all:
        return Icons.all_inclusive;
      case FilterOptions.byDate:
        return Icons.calendar_today;
      case FilterOptions.byPriority:
        return Icons.priority_high;
      case FilterOptions.byTag:
        return Icons.local_offer;
      default:
        return Icons.error;
    }
  }
}

class FilterBottomSheet extends StatelessWidget {
  final ValueChanged<FilterOptions> onFilter;

  const FilterBottomSheet({super.key, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            title: const Text('Filter by Date'),
            onTap: () {
              Navigator.pop(context);
              onFilter(FilterOptions.byDate);
            },
          ),
          ListTile(
            title: const Text('Filter by Priority'),
            onTap: () {
              Navigator.pop(context);
              onFilter(FilterOptions.byPriority);
            },
          ),
          ListTile(
            title: const Text('Filter by Tag'),
            onTap: () {
              Navigator.pop(context);
              onFilter(FilterOptions.byTag);
            },
          ),
          ListTile(
              title: const Text('Display All'),
              onTap: () {
                Navigator.pop(context);
                onFilter(FilterOptions.all);
              })
        ],
      ),
    );
  }
}
