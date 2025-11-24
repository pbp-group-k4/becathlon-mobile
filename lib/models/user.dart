class User {
  final String username;
  final String email;
  final bool isAuthenticated;

  User({
    required this.username,
    required this.email,
    this.isAuthenticated = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isAuthenticated: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }

  // Guest user factory
  factory User.guest() {
    return User(
      username: 'Guest',
      email: '',
      isAuthenticated: false,
    );
  }
}
