class User {
  final int id;
  final String name;
  final String login;
  final String role; // 'student', 'parent', 'teacher'
  final Map<String, dynamic>? profileData;

  User({
    required this.id,
    required this.name,
    required this.login,
    required this.role,
    this.profileData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      login: json['login'] as String,
      role: json['role'] as String? ?? 'parent',
      profileData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'login': login,
      'role': role,
      ...?profileData,
    };
  }
}
