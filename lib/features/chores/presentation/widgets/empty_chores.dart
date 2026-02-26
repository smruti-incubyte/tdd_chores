import 'package:flutter/material.dart';

class EmptyChoresWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyChoresWidget({
    super.key,
    this.title = 'No chores yet',
    this.subtitle = 'Tap the + button to add a chore',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_work_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
