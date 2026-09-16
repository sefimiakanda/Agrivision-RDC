class AgriculteurProfile {
  const AgriculteurProfile({
    this.name = '',
    this.city = '',
    this.mainCulture = '',
    this.farmSize = 0,
  });

  final String name;
  final String city;
  final String mainCulture;
  final double farmSize;

  AgriculteurProfile copyWith({
    String? name,
    String? city,
    String? mainCulture,
    double? farmSize,
  }) {
    return AgriculteurProfile(
      name: name ?? this.name,
      city: city ?? this.city,
      mainCulture: mainCulture ?? this.mainCulture,
      farmSize: farmSize ?? this.farmSize,
    );
  }
}
