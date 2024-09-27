import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {

  final String uid;

  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('User');

  UserService({required this.uid});

  Future addJobSeeker(String name, String gender,
      DateTime birthDate, String email, String phone, String address) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'birth_date': birthDate,
      'email': email,
      'phone': phone,
      'address': address,
      'isJobSeeker': true,
    });
  }

  Future addEmployer(String name, String email, String phone, String address) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'isJobSeeker': false,
    });
  }

}
