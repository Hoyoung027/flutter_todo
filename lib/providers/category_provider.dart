import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../models/category.dart';

// 전역 Provider 선언 — 위젯 트리 어디서든 ref.watch/read로 접근 가능
final categoryProvider = ChangeNotifierProvider<CategoryNotifier>((ref) {
  return CategoryNotifier()..load();
});

class CategoryNotifier extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<Category> _categories = [];

  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> load() async {
    _categories = await _db.getCategories();
    notifyListeners();
  }

  Future<void> add(String name, int color) async {
    final id = await _db.insertCategory(Category(name: name, color: color));
    _categories.add(Category(id: id, name: name, color: color));
    notifyListeners();
  }

  Future<void> update(Category category) async {
    await _db.updateCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    await _db.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Category? findById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
