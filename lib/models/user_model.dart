enum UserRole { employee, janitor, admin }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  final String name;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.employee,
      ),
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.toString().split('.').last,
      'name': name,
    };
  }
}
