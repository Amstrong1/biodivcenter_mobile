class SanitaryState {
  final int id;
  final String label;
  final String animalName;

  SanitaryState({
    required this.id,
    required this.label,
    required this.animalName,
  });

  // Convertit un JSON en objet SanitaryState
  factory SanitaryState.fromJson(Map<String, dynamic> json) {
    return SanitaryState(
      id: json['id'],
      label: json['label'],
      animalName: json['animal_name'],
    );
  }
}
