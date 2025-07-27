class Library {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final String hours;
  final List<String> features;
  final int floors;
  final int capacity;

  const Library({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.hours,
    required this.features,
    required this.floors,
    required this.capacity,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
      hours: json['hours'] as String,
      features: List<String>.from(json['features']),
      floors: json['floors'] as int,
      capacity: json['capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'hours': hours,
      'features': features,
      'floors': floors,
      'capacity': capacity,
    };
  }
}
