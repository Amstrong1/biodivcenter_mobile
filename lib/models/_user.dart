class User {
  final int id;
  final String name;
  final String email;
  final String contact;
  final String role;
  final String ong;
  final String country;
  final String? picture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.role,
    required this.ong,
    required this.country,
    this.picture,
  });

  factory User.fromJson(List<dynamic> json) {
    return User(
      id: json[0]['id'],
      name: json[0]['name'],
      email: json[0]['email'],
      contact: json[0]['contact'],
      role: json[0]['role_label'],
      ong: json[0]['organization'],
      country: json[0]['country'],
      picture: json[0]['picture'],
    );
  }
}
