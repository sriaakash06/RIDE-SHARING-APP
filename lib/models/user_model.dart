class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePic;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePic,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profilePic: data['profilePic'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
    };
  }
}
