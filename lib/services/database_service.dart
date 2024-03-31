import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot snapshot = await usersCollection.get();
    List<Map<String, dynamic>> userList =
        snapshot.docs.map<Map<String, dynamic>>((doc) {
      final data = doc.data()
          as Map<String, dynamic>?; // Ensure data is Map<String, dynamic>
      return {
        if (data != null) ...data, // Use spread operator if data is not null
        'id': doc.id,
      };
    }).toList();
    return userList;
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    await usersCollection.add(userData);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> newData) async {
    await usersCollection.doc(userId).update(newData);
  }

  Future<void> deleteUser(String userId) async {
    await usersCollection.doc(userId).delete();
  }
}
