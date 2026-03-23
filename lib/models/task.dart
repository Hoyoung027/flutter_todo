class Task {
  final int? id;
  final String title;
  final DateTime date;
  final int? categoryId;
  final String? memo;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.date,
    this.categoryId,
    this.memo,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'date': date.toIso8601String().substring(0, 10), // 'yyyy-MM-dd'
      'category_id': categoryId,
      'memo': memo,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as int?,
      memo: map['memo'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    DateTime? date,
    Object? categoryId = _sentinel,
    Object? memo = _sentinel,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as int?,
      memo: memo == _sentinel ? this.memo : memo as String?,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

const _sentinel = Object();
