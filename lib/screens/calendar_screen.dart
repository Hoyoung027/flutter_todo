import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../widgets/task_bottom_sheet.dart';
import 'category_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

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

        // 일정 있는 날짜에 이벤트 마커 전달
        eventLoader: (day) => taskProvider.tasksForDay(day),

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
          // 오늘 날짜
          todayDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

          // 선택된 날짜
          selectedDecoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.blueAccent),

          // 기본 날짜
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white70),

          // 이전/다음 달 날짜
          outsideTextStyle: const TextStyle(color: Colors.white24),

          // 이벤트 마커 (점)
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
