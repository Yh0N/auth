class UserModel {
  final String id;
  final String username;
  final String email;
  final String userId;

  UserModel({required this.id, required this.username, required this.email, required this.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['\$id'],
      username: json['username'],
      email: json['email'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() => {'username': username, 'email': email, 'userId': userId};
}
