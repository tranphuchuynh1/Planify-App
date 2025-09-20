
class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? taskDate;
  final String? taskTime; // Format: "HH:mm"
  final String? category;
  final int? priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.taskDate,
    this.taskTime,
    this.category,
    this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Supabase JSON to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      taskDate: json['task_date'] != null
          ? DateTime.parse(json['task_date'])
          : null,
      taskTime: json['task_time'],
      category: json['category'],
      priority: json['priority'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert Task object to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'task_date': taskDate?.toIso8601String().split('T')[0], // Only date part
      'task_time': taskTime,
      'category': category,
      'priority': priority,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of task with updated values
  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? taskDate,
    String? taskTime,
    String? category,
    int? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskDate: taskDate ?? this.taskDate,
      taskTime: taskTime ?? this.taskTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, isCompleted: $isCompleted}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}