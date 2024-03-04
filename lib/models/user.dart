


class User {
  final int userId;
  final int id;
  final String title;

  const User({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'userId': int userId,
      'id': int id,
      'title': String title,
      } =>
          User(
            userId: userId,
            id: id,
            title: title,
          ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}