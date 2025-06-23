class DummyFriend {
  final String id;
  final String realname;
  final String username;
  final String avatarUrl;
  final String location;
  final String bio;
  final DateTime joinDate;
  final List<String> mutualCrews;
  final List<String> skills;
  final Map<String, int> stats; // posts, projects, followers, following

  const DummyFriend({
    required this.id,
    required this.realname,
    required this.username,
    required this.avatarUrl,
    required this.location,
    required this.bio,
    required this.joinDate,
    required this.mutualCrews,
    required this.skills,
    required this.stats,
  });
}
