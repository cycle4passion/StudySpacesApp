class Profile {
  final String id;
  final List<int> reports;
  final List<int> rank;

  Profile({required this.id, required this.reports, required this.rank});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      reports: (json['reports'] as List<dynamic>).cast<int>(),
      rank: (json['rank'] as List<dynamic>).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'reports': reports, 'rank': rank};
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
}
