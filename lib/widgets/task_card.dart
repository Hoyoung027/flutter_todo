import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category != null ? Color(category!.color) : Colors.white24;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: categoryColor, width: 4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  if (task.memo != null && task.memo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.memo!,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (category != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: categoryColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(category!.name, style: TextStyle(color: categoryColor, fontSize: 11)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
