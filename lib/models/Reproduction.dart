class Reproduction {
  final int id;
  final String phase;
  final String date;
  final String animalName;

  Reproduction({
    required this.id,
    required this.phase,
    required this.date,
    required this.animalName,
  });

  // Convertit un JSON en objet Reproduction
  factory Reproduction.fromJson(Map<String, dynamic> json) {
    return Reproduction(
      id: json['id'],
      phase: json['phase'],
      date: json['date'],
      animalName: json['animal_name'],
    );
  }
}

// "Espèce : ${animal.phase}", 