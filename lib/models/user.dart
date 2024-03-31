// user.dart
class User {
  final String userId;
  final String name;
  final String mobileNumber;
  final String status;

  User({
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.status,
  });

  // Factory method to create a User instance from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      name: map['name'],
      mobileNumber: map['mobileNumber'],
      status: map['status'],
    );
  }

  // Method to convert User instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'mobileNumber': mobileNumber,
      'status': status,
    };
  }
}
