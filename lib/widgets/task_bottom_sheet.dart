import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../screens/task_form_screen.dart';
import 'task_card.dart';

// StatelessWidget → ConsumerWidget
class TaskBottomSheet extends ConsumerWidget {
  final DateTime date;

  const TaskBottomSheet({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch로 상태 구독
    final tasks = ref.watch(taskProvider).tasksForDay(date);
    final categoryNotifier = ref.watch(categoryProvider);
    final dateLabel = '${date.year}년 ${date.month}월 ${date.day}일';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateLabel, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskFormScreen(initialDate: date)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('일정이 없습니다.', style: TextStyle(color: Colors.white38))),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final category = categoryNotifier.findById(task.categoryId);
                  return TaskCard(
                    task: task,
                    category: category,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskFormScreen(initialDate: date, existing: task),
                        ),
                      );
                    },
                    onDelete: () => _confirmDelete(context, ref, task),
                    onToggle: () => ref.read(taskProvider).toggleComplete(task.id!),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('일정 삭제', style: TextStyle(color: Colors.white)),
        content: Text('"${task.title}"을 삭제하시겠습니까?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              // ref.read로 쓰기 작업
              await ref.read(taskProvider).delete(task.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
