
// service.dart
class Service {
  final String serviceId;
  final String serviceName;
  final String serviceDescription;
  final String image;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    required this.image,
  });

  // Factory method to create a Service instance from a Map
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['serviceId'],
      serviceName: map['serviceName'],
      serviceDescription: map['serviceDescription'],
      image: map['image'],
    );
  }

  // Method to convert Service instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceDescription': serviceDescription,
      'image': image,
    };
  }
}

