class Category {
  final int? id;
  final String name;
  final int color; // Color.value (ARGB int)

  Category({this.id, required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      color: map['color'] as int,
    );
  }

  Category copyWith({int? id, String? name, int? color}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
