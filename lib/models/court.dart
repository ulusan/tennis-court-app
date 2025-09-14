enum SurfaceType {
  clay('clay'),
  hard('hard'),
  grass('grass');

  const SurfaceType(this.value);
  final String value;

  static SurfaceType fromString(String value) {
    return SurfaceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SurfaceType.hard,
    );
  }
}


class Court {
  final String id;
  final String name;
  final String location;
  final SurfaceType surfaceType;
  final bool isAvailable;
  final String? imageUrl;
  final List<String> amenities; // lights, roof, etc.
  final String status; // available, busy, maintenance
  final double rating;
  final int capacity;
  final double hourlyRate;

  Court({
    required this.id,
    required this.name,
    required this.location,
    required this.surfaceType,
    this.isAvailable = true,
    this.imageUrl,
    this.amenities = const [],
    this.status = 'available',
    this.rating = 4.5,
    this.capacity = 4,
    this.hourlyRate = 0.0,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      surfaceType: SurfaceType.fromString(json['surface'] ?? 'hard'),
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'],
      amenities: List<String>.from(json['amenities'] ?? []),
      status: json['status'] ?? 'available',
      rating: _parseDouble(json['rating']) ?? 4.5,
      capacity: json['capacity'] ?? 4,
      hourlyRate: _parseDouble(json['hourlyRate']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'surface': surfaceType.value,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'amenities': amenities,
      'status': status,
      'rating': rating,
      'capacity': capacity,
      'hourlyRate': hourlyRate,
    };
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

}
