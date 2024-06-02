
class Task {
  int? id;
  int? userId;
  String label;
  bool done;
  bool priority;
  String day;

  Task({
    this.id,
    this.userId,
    required this.label,
    required this.done,
    required this.priority,
    required this.day
  });

  factory Task.fromJson(Map<dynamic, dynamic> json) {
    return Task(
        id: json['id'],
        userId: json['user']['id'],
        label: json['label'],
        done: json['done'],
        priority: json['priority'],
        day: json['day']
    );
  }
}
