
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
    String startDt, endDt;
    startDt = json['startDT'];
    endDt = json['endDT'];
    
    return Event(
      id: json['id'],
      summary: json['summary'],
      startDt: DateTime.parse(startDt.substring(0, 19)),
      endDt: DateTime.parse(endDt.substring(0, 19)),
      userId: json['User']['id'],
    );
  }

}