class RecyclingCenter {
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  double? distanceKm;

  RecyclingCenter({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.distanceKm,
  });

  RecyclingCenter copyWith({double? distanceKm}) {
    return RecyclingCenter(
      name: name,
      latitude: latitude,
      longitude: longitude,
      category: category,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
