class Relocation {
  final int id;
  final String date;
  final String animalName;
  final String penOrigin;
  final String penDestination;
  final String? comment;

  Relocation({
    required this.id,
    required this.date,
    required this.animalName,
    required this.penOrigin,
    required this.penDestination,
    this.comment,
  });

  // Convertit un JSON en objet Relocation
  factory Relocation.fromJson(Map<String, dynamic> json) {
    return Relocation(
      id: json['id'],
      date: json['date_transfert'],
      animalName: json['animal_name'],
      penOrigin: json['pen_origin'],
      penDestination: json['pen_destination'],
      comment: json['comment'],
    );
  }
}
