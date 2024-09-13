class Animal {
  final int id;
  final String name;
  final String? photo;
  final int specieId;
  final String specieName;
  final String weight;
  final String height;
  final String sex;
  final String birthdate;
  final String createdAt;
  final String origin;
  final String parent;
  final String state;
  final String description;
  final String sanitaryStateLabel;
  final String sanitaryStateDetail;
  // final String lat;
  // final String long;

  Animal({
    required this.id,
    required this.name,
    this.photo,
    required this.specieId,
    required this.specieName,
    required this.sex,
    required this.birthdate,
    required this.createdAt,
    required this.origin,
    required this.parent,
    required this.state,
    required this.description,
    required this.weight,
    required this.height,
    required this.sanitaryStateLabel,
    required this.sanitaryStateDetail,
    // required this.lat,
    // required this.long,
  });

  // Convertit un JSON en objet Animal
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      specieId: json['id'],
      specieName: json['specie_name'],
      sex: json['sex'],
      birthdate: json['birthdate'],
      createdAt: json['formated_created_at'],
      origin: json['origin'],
      parent: json['parent'],
      state: json['state'],
      description: json['description'],
      weight: json['weight'],
      height: json['height'],
      sanitaryStateLabel: json['sanitary_state_label'],
      sanitaryStateDetail: json['sanitary_state_detail'],
      // lat: json['lat'],
      // long: json['long'],
    );
  }
}
