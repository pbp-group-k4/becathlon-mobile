class Profile {
  final String username;
  String firstName;
  String lastName;
  String email;
  String phone;
  String preferredSports;
  bool newsletterOptIn;

  Profile({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.preferredSports,
    required this.newsletterOptIn,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      username: json['username'],
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      preferredSports: json['preferred_sports'] ?? "",
      newsletterOptIn: json['newsletter_opt_in'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "preferred_sports": preferredSports,
      "newsletter_opt_in": newsletterOptIn,
    };
  }
}
