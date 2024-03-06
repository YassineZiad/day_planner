
class User {
  final int id;
  final String nickname;
  final String mail;

  const User({
    required this.id,
    required this.nickname,
    required this.mail
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'id': int id,
      'nickname': String nickname,
      'mail': String mail
      } =>
          User(
            id: id,
            nickname: nickname,
            mail: mail,
          ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}