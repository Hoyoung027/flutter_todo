import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_chip.dart';

// StatefulWidget → ConsumerStatefulWidget
class TaskFormScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final Task? existing;
  final int? initialCategoryId;

  const TaskFormScreen({
    super.key,
    required this.initialDate,
    this.existing,
    this.initialCategoryId,
  });

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _memoController = TextEditingController(text: widget.existing?.memo ?? '');
    _selectedDate = widget.existing?.date ?? widget.initialDate;
    _selectedCategoryId = widget.existing?.categoryId ?? widget.initialCategoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    // context.read → ref.read
    final notifier = ref.read(taskProvider);
    final memo = _memoController.text.trim().isEmpty ? null : _memoController.text.trim();

    if (widget.existing == null) {
      await notifier.add(Task(
        title: title,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        memo: memo,
      ));
    } else {
      await notifier.update(widget.existing!.copyWith(
        title: title,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        memo: memo,
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch로 카테고리 목록 구독
    final categories = ref.watch(categoryProvider).categories;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.existing == null ? '일정 추가' : '일정 수정'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              ),
              autofocus: widget.existing == null,
            ),
            const SizedBox(height: 24),
            const _SectionLabel(label: '날짜'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionLabel(label: '카테고리'),
            const SizedBox(height: 10),
            if (categories.isEmpty)
              const Text('카테고리가 없습니다.', style: TextStyle(color: Colors.white38, fontSize: 13))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(20),
                        color: _selectedCategoryId == null ? Colors.white12 : Colors.transparent,
                      ),
                      child: const Text('없음', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                  ),
                  ...categories.map((cat) => CategoryChip(
                    category: cat,
                    selected: _selectedCategoryId == cat.id,
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                  )),
                ],
              ),
            const SizedBox(height: 24),
            const _SectionLabel(label: '메모'),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '메모 (선택)',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Color(0xFF1C1C1E),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600));
  }
}
