import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

// StatelessWidget → ConsumerWidget
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // context.watch → ref.watch
    final notifier = ref.watch(categoryProvider);
    final categories = notifier.categories;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('카테고리 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context, ref, null),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                '카테고리가 없습니다.\n+ 버튼으로 추가해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Color(cat.color), radius: 14),
                  title: Text(cat.name, style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                        onPressed: () => _showCategoryDialog(context, ref, cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        onPressed: () => _confirmDelete(context, ref, cat),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, Category? existing) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    Color pickedColor = existing != null ? Color(existing.color) : Colors.blueAccent;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              title: Text(
                existing == null ? '카테고리 추가' : '카테고리 수정',
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: '이름',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      Color temp = pickedColor;
                      await showDialog(
                        context: ctx,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1C1C1E),
                          title: const Text('색상 선택', style: TextStyle(color: Colors.white)),
                          content: BlockPicker(
                            pickerColor: pickedColor,
                            onColorChanged: (c) => temp = c,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('확인', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      setState(() => pickedColor = temp);
                    },
                    child: Row(
                      children: [
                        const Text('색상', style: TextStyle(color: Colors.white54)),
                        const SizedBox(width: 16),
                        CircleAvatar(backgroundColor: pickedColor, radius: 16),
                        const SizedBox(width: 8),
                        const Text('탭하여 선택', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('취소', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    // context.read 대신 ref.read
                    final notifier = ref.read(categoryProvider);
                    if (existing == null) {
                      await notifier.add(name, pickedColor.toARGB32());
                    } else {
                      await notifier.update(existing.copyWith(name: name, color: pickedColor.toARGB32()));
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('저장', style: TextStyle(color: Colors.blueAccent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('카테고리 삭제', style: TextStyle(color: Colors.white)),
        content: Text(
          '"${cat.name}" 카테고리를 삭제하면 해당 카테고리의 일정 연결이 해제됩니다.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(categoryProvider).delete(cat.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
