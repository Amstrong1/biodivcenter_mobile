class Animal {
  final int id;
  final String name;
  final String weight;
  final String height;
  final String sex;
  final String birthdate;
  final String description;
  final String photo;
  final String state;
  final String origin;
  final String parent;
  final String specie;

  Animal({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.sex,
    required this.birthdate,
    required this.description,
    required this.photo,
    required this.state,
    required this.origin,
    required this.parent,
    required this.specie,
  });

  // Convertit un JSON en objet Animal
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      weight: json['weight'],
      height: json['height'],
      sex: json['sex'],
      birthdate: json['birthdate'],
      description: json['description'],
      photo: json['photo'],
      state: json['state'],
      origin: json['origin'],
      parent: json['parent'],
      specie: json['specie'],
    );
  }
}
