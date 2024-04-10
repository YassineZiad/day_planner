
class Event {
  int? id;
  int? userId;
  final String summary;
  final DateTime startDt;
  final DateTime endDt;

  Event({
    this.id,
    this.userId,
    required this.summary,
    required this.startDt,
    required this.endDt
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      summary: json['summary'],
      startDt: DateTime.parse(json['startDT'].substring(0, 19)),
      endDt: DateTime.parse(json['endDT'].substring(0, 19)),
      userId: json['User']['id'],
    );

  }

}
