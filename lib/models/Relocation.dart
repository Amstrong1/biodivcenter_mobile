class Relocation {
  final int id;
  final String date;
  final String animalName;

  Relocation({
    required this.id,
    required this.date,
    required this.animalName,
  });

  // Convertit un JSON en objet Relocation
  factory Relocation.fromJson(Map<String, dynamic> json) {
    return Relocation(
      id: json['id'],
      date: json['date_transfert'],
      animalName: json['animal_name'],
    );
  }
}
