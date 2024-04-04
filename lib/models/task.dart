
class Task {
  int? id;
  int? userId;
  String label;
  bool priority;
  String day;

  Task({
    this.id,
    this.userId,
    required this.label,
    required this.priority,
    required this.day
  });

  factory Task.fromJson(Map<dynamic, dynamic> json) {
    return Task(
        id: json['id'],
        userId: json['user']['id'],
        label: json['label'],
        priority: json['priority'],
        day: json['day']
    );
  }
}

