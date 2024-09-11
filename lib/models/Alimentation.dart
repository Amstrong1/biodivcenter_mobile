class Alimentation {
  final int id;
  final String food;
  final String specieName;

  Alimentation({
    required this.id,
    required this.food,
    required this.specieName,
  });

  // Convertit un JSON en objet Alimentation
  factory Alimentation.fromJson(Map<String, dynamic> json) {
    return Alimentation(
      id: json['id'],
      food: json['food'],
      specieName: json['specie_name'],
    );
  }
}
