class User {
  final String id;
  final String nickname;
  final String role; // 예: '엄마', '아빠', '조부모' 등
  final String email;

  User({
    required this.id,
    required this.nickname,
    required this.role,
    required this.email,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      nickname: data['nickname'],
      role: data['role'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'role': role,
      'email': email,
    };
  }
}