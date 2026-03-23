import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: selected ? color : Colors.white70,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
