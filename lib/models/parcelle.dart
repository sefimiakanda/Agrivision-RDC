class Parcelle {
  const Parcelle({
    this.id,
    required this.ville,
    required this.nom,
    required this.culture,
    required this.superficie,
  });

  final int? id;
  final String ville;
  final String nom;
  final String culture;
  final double superficie;

  Parcelle copyWith({
    int? id,
    String? ville,
    String? nom,
    String? culture,
    double? superficie,
  }) {
    return Parcelle(
      id: id ?? this.id,
      ville: ville ?? this.ville,
      nom: nom ?? this.nom,
      culture: culture ?? this.culture,
      superficie: superficie ?? this.superficie,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'ville': ville,
      'nom': nom,
      'culture': culture,
      'superficie': superficie,
    };
  }

  factory Parcelle.fromMap(Map<String, Object?> map) {
    return Parcelle(
      id: map['id'] as int?,
      ville: map['ville'] as String,
      nom: map['nom'] as String,
      culture: map['culture'] as String,
      superficie: (map['superficie'] as num).toDouble(),
    );
  }
}
