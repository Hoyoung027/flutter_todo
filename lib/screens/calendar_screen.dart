import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../widgets/task_bottom_sheet.dart';
import 'category_screen.dart';

// StatefulWidget → ConsumerStatefulWidget (ref 사용 + 로컬 상태 유지)
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // context.watch 대신 ref.watch
    final taskNotifier = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('캘린더', style: TextStyle(color: Colors.white)),
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
      body: TableCalendar(
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: '월간'},
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) => taskNotifier.tasksForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TaskBottomSheet(date: selectedDay),
          );
        },
        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.blueAccent),
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white70),
          outsideTextStyle: const TextStyle(color: Colors.white24),
          markerDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          markerSize: 5,
          markersMaxCount: 3,
          markersAlignment: Alignment.bottomCenter,
          cellMargin: const EdgeInsets.all(4),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white54, fontSize: 12),
          weekendStyle: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
    );
  }
}
