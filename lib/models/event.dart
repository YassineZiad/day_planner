
class Event {
  final int id;
  final int userId;
  final String summary;
  final DateTime startDt;
  final DateTime endDt;

  const Event({
    required this.id,
    required this.userId,
    required this.summary,
    required this.startDt,
    required this.endDt
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'id': int id,
      'userId': int userId,
      'summary': String summary,
      'startDt': DateTime startDt,
      'endDt': DateTime endDt
      } =>
          Event(
            id: id,
            userId: userId,
            summary: summary,
            startDt: startDt,
            endDt: endDt
          ),
      _ => throw const FormatException('Failed to load Event.'),
    };
  }
}