class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String ong;
  final String? picture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.ong,
    this.picture,
  });

  factory User.fromJson(List<dynamic> json) {
    return User(
      id: json[0]['id'],
      name: json[0]['name'],
      email: json[0]['email'],
      role: json[0]['role_label'],
      ong: json[0]['organization'],
      picture: json[0]['picture'],
    );
  }
}
