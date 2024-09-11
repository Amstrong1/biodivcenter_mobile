class Animal {
  final int id;
  final String name;
  final String? photo;
  final String specieName;

  Animal({
    required this.id,
    required this.name,
    this.photo,
    required this.specieName,
  });

  // Convertit un JSON en objet Animal
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      specieName: json['specie_name'],
    );
  }
}
