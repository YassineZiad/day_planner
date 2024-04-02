
class Note {
  String day;
  int? userId;
  String text;

  Note({
    this.userId,
    required this.text,
    required this.day
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      day: json['day'],
      userId: json['user']['id'],
      text: json['text']
    );
  }
}