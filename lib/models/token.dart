// token.dart
class Token {
  final int tokenNumber;
  final int jobNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String mobileNumber;
  final String status;

  Token({
    required this.tokenNumber,
    required this.jobNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.mobileNumber,
    required this.status,
  });

  // Factory method to create a Token instance from a Map
  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      tokenNumber: map['tokenNumber'],
      jobNumber: map['jobNumber'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      mobileNumber: map['mobileNumber'],
      status: map['status'],
    );
  }

  // Method to convert Token instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'tokenNumber': tokenNumber,
      'jobNumber': jobNumber,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'mobileNumber': mobileNumber,
      'status': status,
    };
  }
}
