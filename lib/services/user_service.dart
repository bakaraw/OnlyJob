import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:only_job/models/user.dart';

class UserService {
  final String uid;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('User');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserService({required this.uid});

  Future addUser(String name, String? gender, DateTime? birthDate, String email,
      String phone, String address, bool isJobSeeker) async {
    try {
      return await userCollection.doc(uid).set({
        'name': name,
        'birth_date': birthDate,
        'email': email,
        'gender': gender,
        'phone': phone,
        'address': address,
        'isJobSeeker': isJobSeeker,
        'contacts': [],
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    log(snapshot.get('name'));
    if (snapshot.get('isJobSeeker') == true) {
      return UserData(
        uid: uid,
        name: snapshot.get('name'),
        email: snapshot.get('email'),
        phone: snapshot.get('phone'),
        address: snapshot.get('address'),
        isJobSeeker: snapshot.get('isJobSeeker'),
        birthDate: snapshot.get('birth_date').toDate(),
        gender: snapshot.get('gender'),
      );
    }

    return UserData(
      uid: uid,
      name: snapshot.get('name'),
      email: snapshot.get('email'),
      phone: snapshot.get('phone'),
      address: snapshot.get('address'),
      isJobSeeker: snapshot.get('isJobSeeker'),
      birthDate: null,
      gender: null,
    );
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
