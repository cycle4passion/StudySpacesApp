class Space {
  final String id;
  final int? reservationid; // Optional reservation ID
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
  final String phone;

  Space({
    required this.id,
    this.reservationid, // Optional parameter
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
    required this.phone,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'],
      reservationid: json['reservationid'], // Will be null if not present
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
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (reservationid != null)
        'reservationid': reservationid, // Only include if not null
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
      'phone': phone,
    };
  }
}

class LeaderboardEntry {
  final String name;
  final int reports;

  LeaderboardEntry({required this.name, required this.reports});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(name: json['name'], reports: json['reports']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'reports': reports};
  }
}

class Leaderboard {
  final List<LeaderboardEntry> day;
  final List<LeaderboardEntry> week;
  final List<LeaderboardEntry> month;
  final List<LeaderboardEntry> alltime;

  Leaderboard({
    required this.day,
    required this.week,
    required this.month,
    required this.alltime,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      day: (json['day'] as List)
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList(),
      week: (json['week'] as List)
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList(),
      month: (json['month'] as List)
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList(),
      alltime: (json['alltime'] as List)
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.map((entry) => entry.toJson()).toList(),
      'week': week.map((entry) => entry.toJson()).toList(),
      'month': month.map((entry) => entry.toJson()).toList(),
      'alltime': alltime.map((entry) => entry.toJson()).toList(),
    };
  }
}
