class UserProfile {
  String? name;
  String? email;
  String? phone;
  String? avatar;

  UserProfile({
    this.name,
    this.email,
    this.phone,
    this.avatar,
  });

  factory UserProfile.fromMap(Map<String, String?> data) {
    return UserProfile(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      avatar: data['avatar'],
    );
  }

  Map<String, String?> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
