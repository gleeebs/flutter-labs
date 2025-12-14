class Task {
  final String id;
  final String title;
  final String category;
  final String priority;
  final String? description;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    this.description,
    this.isCompleted = false,
  });

  // Конструктор из формы
  factory Task.fromForm({
    required String title,
    required String category,
    required String priority,
    String? description,
  }) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      priority: priority,
      description: description,
    );
  }

  // JSON сериализация
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'priority': priority,
    'description': description,
    'isCompleted': isCompleted,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
