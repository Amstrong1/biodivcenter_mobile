class Reproduction {
  final int id;
  final String phase;
  final String date;
  final String animalName;
  final int litterSize;
  final String? observation;

  Reproduction({
    required this.id,
    required this.phase,
    required this.date,
    required this.animalName,
    required this.litterSize,
    required this.observation,
  });

  // Convertit un JSON en objet Reproduction
  factory Reproduction.fromJson(Map<String, dynamic> json) {
    return Reproduction(
      id: json['id'],
      phase: json['phase'],
      date: json['date'],
      animalName: json['animal_name'],
      litterSize: json['litter_size'],
      observation: json['observation'],
    );
  }
}
