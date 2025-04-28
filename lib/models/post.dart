class Post {
  final int id;
  final String type;
  final String region;
  final DateTime startedAt;
  final DateTime endedAt;
  final int pay;
  final String desc;
  final String status;
  final User user;

  Post({
    required this.id,
    required this.type,
    required this.region,
    required this.startedAt,
    required this.endedAt,
    required this.pay,
    required this.desc,
    required this.status,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      type: json['type'] == 'work' ? '구직' : '구인',
      region: json['region'],
      startedAt: DateTime.parse(json['startDate']),
      endedAt: DateTime.parse(json['endDate']),
      pay: json['pay'],
      desc: json['description'],
      status: json['status'],
      user: json['user'] != null ? User.fromJson(json['user']) : User.empty(),
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String phoneNumber;
  final String region;
  final String? nickname;
  final String? profileImageUrl;
  final bool isVerified;
  final List<Pet> pets;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.region,
    this.nickname,
    this.profileImageUrl,
    required this.isVerified,
    required this.pets,
  });

  User.empty()
    : id = 0,
      username = '',
      email = '',
      phoneNumber = '',
      region = '',
      nickname = null,
      profileImageUrl = null,
      isVerified = false,
      pets = [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      region: json['region'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      isVerified: json['isVerified'],
      pets:
          (json['pet'] != null && json['pet'] is List)
              ? (json['pet'] as List).map((p) => Pet.fromJson(p)).toList()
              : [],
    );
  }
}

class Pet {
  final int id;
  final String name;
  final String type;
  final String image;
  final String? description;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    this.description,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      image: json['image'],
      description: json['description'],
    );
  }
}
