
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

// {
// "id":7,
// "summary":"Bagarre",
// "startDT":"2024-02-13T11:30:00+01:00",
// "endDT":"2024-02-13T12:00:00+01:00",
// "User":{"id":3,"nickname":"yass","mail":"yassine.ziad@hesias.fr"}
// }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      summary: json['summary'],
      startDt: DateTime.parse(json['startDT']),
      endDt: DateTime.parse(json['endDT']),
      userId: json['User']['id'],
    );
  }

}