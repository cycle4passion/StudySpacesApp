class Library {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final double range;
  final List<int> openat;
  final List<int> closeat;
  final List<String> features;
  final int floors;
  final int capacity;
  final int fullness;
  final bool isFavorite;
  final String phone;

  Library({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.range,
    required this.openat,
    required this.closeat,
    required this.features,
    required this.floors,
    required this.capacity,
    required this.fullness,
    required this.isFavorite,
    required this.phone,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      category: json['category'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      range: json['range'].toDouble(),
      openat: List<int>.from(json['openat']),
      closeat: List<int>.from(json['closeat']),
      features: List<String>.from(json['features']),
      floors: json['floors'],
      capacity: json['capacity'],
      fullness: json['fullness'],
      isFavorite: json['isFavorite'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'range': range,
      'openat': openat,
      'closeat': closeat,
      'features': features,
      'floors': floors,
      'capacity': capacity,
      'fullness': fullness,
      'isFavorite': isFavorite,
      'phone': phone,
    };
  }
}
