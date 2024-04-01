import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, int>> generateTokenAndJobNo() async {
  // Reference to the tokens collection
  CollectionReference tokensCollection =
      FirebaseFirestore.instance.collection('tokens');

  // Get the last token document
  QuerySnapshot lastTokenSnapshot = await tokensCollection
      .orderBy('tokenNo', descending: true)
      .limit(1)
      .get();
  int lastTokenNo = 1000;

  if (lastTokenSnapshot.docs.isNotEmpty) {
    lastTokenNo = int.parse(lastTokenSnapshot.docs.first['tokenNo']);
  }

  // Increment the last tokenNo
  int newTokenNo = (lastTokenNo + 1) % 10000; // Ensure 4-digit format

  // Reference to the token collection
  CollectionReference jobsCollection =
      FirebaseFirestore.instance.collection('tokens');

  // Get the last job document
  QuerySnapshot lastJobSnapshot =
      await jobsCollection.orderBy('jobNo', descending: true).limit(1).get();
  int lastJobNo = 2000;

  if (lastJobSnapshot.docs.isNotEmpty) {
    lastJobNo = int.parse(lastJobSnapshot.docs.first['jobNo']);
  }

  // Increment the last jobNo
  int newJobNo = (lastJobNo + 1) % 10000; // Ensure 4-digit format

  return {
    'tokenNo': newTokenNo,
    'jobNo': newJobNo,
  };
}
