class Alimentation {
  final int id;
  final String food;
  final int specieId;
  final String specieName;
  final String ageRange;
  final String frequency;
  final int quantity;
  final String cost;

  Alimentation({
    required this.id,
    required this.food,
    required this.specieName,
    required this.specieId,
    required this.ageRange,
    required this.frequency,
    required this.quantity,
    required this.cost,
  });

  // Convertit un JSON en objet Alimentation
  factory Alimentation.fromJson(Map<String, dynamic> json) {
    return Alimentation(
      id: json['id'],
      food: json['food'],
      specieId: json['specie_id'],
      specieName: json['specie_name'],
      ageRange: json['age_range'],
      frequency: json['frequency'],
      quantity: json['quantity'],
      cost: json['cost'],
    );
  }
}
