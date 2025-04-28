class MyUser {
  final int id;
  final String username;
  final String email;
  final String phoneNumber;
  final String region;
  final String? nickname;
  final String? profileImageUrl;
  final bool isVerified;

  MyUser({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.region,
    this.nickname,
    this.profileImageUrl,
    required this.isVerified,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      region: json['region'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      isVerified: json['isVerified'],
    );
  }
}
