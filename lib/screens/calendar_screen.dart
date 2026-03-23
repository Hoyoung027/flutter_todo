import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/task_card.dart';
import 'category_screen.dart';
import 'task_form_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final taskNotifier = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('To-Do', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white70),
            tooltip: '카테고리 관리',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            daysOfWeekHeight: 22,
            availableCalendarFormats: const {CalendarFormat.month: '월간'},
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, focusedDay) => Center(
                child: Text(
                  '${focusedDay.year}년 ${focusedDay.month}월',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              dowBuilder: (context, day) {
                const labels = ['월', '화', '수', '목', '금', '토', '일'];
                final label = labels[day.weekday - 1];
                Color color;
                if (day.weekday == DateTime.saturday) {
                  color = Colors.blueAccent;
                } else if (day.weekday == DateTime.sunday) {
                  color = Colors.redAccent;
                } else {
                  color = Colors.white;
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      label,
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) =>
                  _buildCell(day, taskNotifier, isToday: false, isSelected: false),
              todayBuilder: (context, day, focusedDay) =>
                  _buildCell(day, taskNotifier, isToday: true, isSelected: false),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildCell(day, taskNotifier, isToday: isSameDay(day, DateTime.now()), isSelected: true),
              outsideBuilder: (context, day, focusedDay) =>
                  _buildCell(day, taskNotifier, isToday: false, isSelected: false, outside: true),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white, fontSize: 12),
              weekendStyle: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _DayTaskList(selectedDay: _selectedDay),
          ),
        ],
      ),
    );
  }

  Color _dateColor(DateTime day, {required bool outside, required bool isSelected}) {
    if (isSelected) return Colors.black;
    if (outside) return Colors.white24;
    if (day.weekday == DateTime.saturday) return Colors.blueAccent;
    if (day.weekday == DateTime.sunday) return Colors.redAccent;
    return Colors.white;
  }

  Widget _buildCell(
    DateTime day,
    TaskNotifier notifier, {
    required bool isToday,
    required bool isSelected,
    bool outside = false,
  }) {
    final tasks = notifier.tasksForDay(day);
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final allDone = total > 0 && completed == total;
    final incomplete = total - completed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellH = constraints.maxHeight;
        const fontSize = 11.0;
        final iconSize = cellH * 0.42;
        final dateSize = cellH * 0.42;
        final gap = cellH * 0.05;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: total == 0
                  ? _NoTodoIcon(count: 0, fontSize: fontSize)
                  : allDone
                      ? _AllDoneIcon()
                      : _CountIcon(count: incomplete, fontSize: fontSize),
            ),
            SizedBox(height: gap),
            Container(
              width: dateSize,
              height: dateSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday && !isSelected
                    ? Colors.grey[850]
                    : isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: _dateColor(day, outside: outside, isSelected: isSelected),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: gap),
          ],
        );
      },
    );
  }
}

// ─── 인라인 할일 목록 ─────────────────────────────────────────────────────────

class _DayTaskList extends ConsumerWidget {
  final DateTime? selectedDay;
  const _DayTaskList({required this.selectedDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.watch(taskProvider);
    final categoryNotifier = ref.watch(categoryProvider);
    final categories = categoryNotifier.categories;

    // 날짜 미선택: 카테고리 헤더만 표시
    if (selectedDay == null) {
      if (categories.isEmpty) {
        return const Center(
          child: Text('카테고리가 없습니다.', style: TextStyle(color: Colors.white38)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (_, i) => _CategoryHeader(
          color: Color(categories[i].color),
          name: categories[i].name,
          onAdd: () => _openCreateTask(
            context,
            selectedDay: selectedDay,
            categoryId: categories[i].id,
          ),
        ),
      );
    }

    // 날짜 선택: 카테고리별 그룹핑
    final tasks = taskNotifier.tasksForDay(selectedDay!);
    final Map<int?, List<Task>> grouped = {};
    for (final t in tasks) {
      grouped.putIfAbsent(t.categoryId, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [

        // 카테고리별 섹션 (categoryProvider 순서 기준)
        for (final cat in categories) ...[
          _CategoryHeader(
            color: Color(cat.color),
            name: cat.name,
            onAdd: () => _openCreateTask(
              context,
              selectedDay: selectedDay,
              categoryId: cat.id,
            ),
          ),
          if (grouped.containsKey(cat.id))
            ...grouped[cat.id]!.map(
              (task) => _buildCard(context, ref, task, selectedDay!),
            ),
        ],

        // 카테고리 없음 섹션 (맨 아래)
        if (grouped.containsKey(null)) ...[
          const Padding(
            padding: EdgeInsets.only(top: 4),
          ),
          _CategoryHeader(
            color: Colors.white24,
            name: '카테고리 없음',
            onAdd: () => _openCreateTask(
              context,
              selectedDay: selectedDay,
              categoryId: null,
            ),
          ),
          ...grouped[null]!.map(
            (task) => _buildCard(context, ref, task, selectedDay!),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Task task, DateTime date) {
    final category = ref.read(categoryProvider).findById(task.categoryId);
    return TaskCard(
      task: task,
      category: category,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskFormScreen(initialDate: date, existing: task),
        ),
      ),
      onDelete: () => _confirmDelete(context, ref, task),
      onToggle: () => ref.read(taskProvider).toggleComplete(task.id!),
    );
  }

  void _openCreateTask(
    BuildContext context, {
    required DateTime? selectedDay,
    required int? categoryId,
  }) {
    final initialDate = selectedDay ?? DateTime.now();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          initialDate: initialDate,
          initialCategoryId: categoryId,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('일정 삭제', style: TextStyle(color: Colors.white)),
        content: Text('"${task.title}"을 삭제하시겠습니까?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
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

class _CategoryHeader extends StatelessWidget {
  final Color color;
  final String name;
  final VoidCallback onAdd;
  const _CategoryHeader({
    required this.color,
    required this.name,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(110),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                width: 20,
                height: 20,
                child: IconButton(
                  onPressed: onAdd,
                  padding: EdgeInsets.zero,
                  splashRadius: 14,
                  icon: Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 셀 아이콘 ────────────────────────────────────────────────────────────────

class _AllDoneIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: const Icon(Icons.check, size: 16, color: Colors.white, weight: 900),
    );
  }
}

class _CountIcon extends StatelessWidget {
  final int count;
  final double fontSize;
  const _CountIcon({required this.count, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NoTodoIcon extends StatelessWidget {
  final int count;
  final double fontSize;
  const _NoTodoIcon({required this.count, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      alignment: Alignment.center,
    );
  }
}

