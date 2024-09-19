class SanitaryState {
  final int id;
  final String label;
  final String animalName;
  final String description;
  final String? correctiveAction;
  final String cost;
  final int? temperature;
  final int? height;
  final int? weight;
  final String date;
  
  

  SanitaryState({
    required this.id,
    required this.label,
    required this.animalName,
    required this.description,
    this.correctiveAction,
    required this.cost,
    this.temperature,
    this.height,
    this.weight,
    required this.date,
  });

  // Convertit un JSON en objet SanitaryState
  factory SanitaryState.fromJson(Map<String, dynamic> json) {
    return SanitaryState(
      id: json['id'],
      label: json['label'],
      animalName: json['animal_name'],
      description: json['description'],
      correctiveAction: json['corrective_action'],
      cost: json['cost'],
      temperature: json['temperature'],
      height: json['height'],
      weight: json['weight'],
      date: json['formated_date'],
    );
  }
}
