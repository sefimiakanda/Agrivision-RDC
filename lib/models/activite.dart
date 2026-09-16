class Activite {
  const Activite({
    this.id,
    required this.parcelleId,
    required this.type,
    required this.date,
    required this.description,
  });

  final int? id;
  final int parcelleId;
  final String type;
  final DateTime date;
  final String description;

  Activite copyWith({
    int? id,
    int? parcelleId,
    String? type,
    DateTime? date,
    String? description,
  }) {
    return Activite(
      id: id ?? this.id,
      parcelleId: parcelleId ?? this.parcelleId,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'parcelle_id': parcelleId,
      'type': type,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Activite.fromMap(Map<String, Object?> map) {
    return Activite(
      id: map['id'] as int?,
      parcelleId: map['parcelle_id'] as int,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
    );
  }
}
