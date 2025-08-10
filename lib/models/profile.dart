class Profile {
  final String id;
  final List<int> reports;
  final List<int> rank;
  final List<String> favorites;
  final List<String> selectedFilters;
  bool darkMode;

  Profile({
    required this.id,
    required this.reports,
    required this.rank,
    required this.favorites,
    required this.selectedFilters,
    this.darkMode = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      reports: (json['reports'] as List<dynamic>).cast<int>(),
      rank: (json['rank'] as List<dynamic>).cast<int>(),
      favorites: (json['favorites'] as List<dynamic>).cast<String>(),
      selectedFilters:
          (json['selectedFilters'] as List<dynamic>?)?.cast<String>() ?? [],
      darkMode: json['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reports': reports,
      'rank': rank,
      'favorites': favorites,
      'selectedFilters': selectedFilters,
      'darkMode': darkMode,
    };
  }

  // Helper methods for reports
  int get totalReports => reports.fold(0, (sum, report) => sum + report);

  int get averageReports =>
      reports.isEmpty ? 0 : (totalReports / reports.length).round();

  int get highestReports =>
      reports.isEmpty ? 0 : reports.reduce((a, b) => a > b ? a : b);

  int get lowestReports =>
      reports.isEmpty ? 0 : reports.reduce((a, b) => a < b ? a : b);

  // Helper methods for rank
  int get currentRank => rank.isEmpty ? 0 : rank.last;

  int get bestRank => rank.isEmpty ? 0 : rank.reduce((a, b) => a < b ? a : b);

  int get worstRank => rank.isEmpty ? 0 : rank.reduce((a, b) => a > b ? a : b);

  double get averageRank =>
      rank.isEmpty ? 0.0 : rank.fold(0, (sum, r) => sum + r) / rank.length;

  // Check if rank is improving (lower numbers are better)
  bool get isRankImproving {
    if (rank.length < 2) return false;
    return rank.last < rank[rank.length - 2];
  }

  // Helper methods for favorites
  bool isFavorite(String spaceId) {
    return favorites.contains(spaceId);
  }

  List<String> get favoriteSpaces => favorites;

  // Helper methods for time period specific data
  int get dailyReports => reports.isNotEmpty ? reports[0] : 0;
  int get weeklyReports => reports.length > 1 ? reports[1] : 0;
  int get monthlyReports => reports.length > 2 ? reports[2] : 0;
  int get alltimeReports => reports.length > 3 ? reports[3] : 0;

  int get dailyRank => rank.isNotEmpty ? rank[0] : 0;
  int get weeklyRank => rank.length > 1 ? rank[1] : 0;
  int get monthlyRank => rank.length > 2 ? rank[2] : 0;
  int get alltimeRank => rank.length > 3 ? rank[3] : 0;
}
