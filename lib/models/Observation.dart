class Observation {
  final int id;
  final String subject;
  final String content;
  final String date;


  Observation({
    required this.id,
    required this.subject,
    required this.date,
    required this.content,
  });

  // Convertit un JSON en objet Observation
  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'],
      subject: json['subject'],
      date: json['formated_date'],
      content: json['observation'],
    );
  }
}
