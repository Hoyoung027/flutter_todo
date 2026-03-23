import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../widgets/task_bottom_sheet.dart';
import 'category_screen.dart';

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
      body: TableCalendar(
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: '월간'},
        startingDayOfWeek: StartingDayOfWeek.monday,

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

        // 커스텀 셀 빌더
        calendarBuilders: CalendarBuilders(
          // 헤더 타이틀: "2026년 3월" 형식
          headerTitleBuilder: (context, focusedDay) => Center(
            child: Text(
              '${focusedDay.year}년 ${focusedDay.month}월',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          // 요일 행: 월화수목금토일, 토=파랑 / 일=빨강
          dowBuilder: (context, day) {
            const labels = ['월', '화', '수', '목', '금', '토', '일'];
            final label = labels[day.weekday - 1];
            Color color;
            if (day.weekday == DateTime.saturday) {
              color = Colors.blueAccent;
            } else if (day.weekday == DateTime.sunday) {
              color = Colors.redAccent;
            } else {
              color = Colors.white54;
            }
            return Center(
              child: Text(label, style: TextStyle(color: color, fontSize: 12)),
            );
          },
          // 일반 날짜
          defaultBuilder: (context, day, focusedDay) =>
              _buildCell(day, taskNotifier, isToday: false, isSelected: false),
          // 오늘
          todayBuilder: (context, day, focusedDay) =>
              _buildCell(day, taskNotifier, isToday: true, isSelected: false),
          // 선택된 날짜
          selectedBuilder: (context, day, focusedDay) =>
              _buildCell(day, taskNotifier, isToday: isSameDay(day, DateTime.now()), isSelected: true),
          // 이전/다음 달 날짜
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
          weekdayStyle: TextStyle(color: Colors.white54, fontSize: 12),
          weekendStyle: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
    );
  }

  // 날짜 기본 색상 (토=파랑, 일=빨강, 평일=흰색)
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

    // LayoutBuilder로 실제 셀 크기를 읽어서 비율 계산
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellH = constraints.maxHeight;
        const fontSize = 11.0;
        final iconSize = cellH * 0.42;
        final dateSize = cellH * 0.42;
        final gap = cellH * 0.07;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 영역
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: total == 0
                  ? null
                  : allDone
                      ? _AllDoneIcon()
                      : _CountIcon(count: incomplete, fontSize: fontSize),
            ),
            SizedBox(height: gap),
            // 날짜 숫자
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
          ],
        );
      },
    );
  }
}

// 전부 완료 → 파란 박스 + 흰 체크마크
class _AllDoneIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: const Icon(Icons.check, size: 16, color: Colors.white),
    );
  }
}

// 미완료 개수 표시 → 회색 원 + 흰 숫자
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
