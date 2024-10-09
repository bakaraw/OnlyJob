import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:only_job/models/user.dart';
import 'package:only_job/services/auth.dart';
import 'package:only_job/views/constants/constants.dart';
import '../views/constants/loading.dart';

class UserSearchDelegate extends SearchDelegate {


  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;



  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          close(context, null);

        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }




  Future<void> _addContact(String contactId) async {
    String currentUserId = auth.currentUser!.uid;
    DocumentReference userDocRef = firestore.collection('User').doc(currentUserId);

    await userDocRef.update({
      'contacts': FieldValue.arrayUnion([contactId]),
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('User')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: Loading());
        }
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;

            final String userName = userData['name'] ?? 'No Name';
            final String userEmail = userData['email'] ?? 'No Email';

            return ListTile(
              title: Text(userName, style: usernameStyle,),
              subtitle: Text(userEmail, style: emailStyle,),
              onTap: () async {
                final userExistNotPush = await firestore
                    .collection('User')
                    .where('name', isEqualTo: userName)
                    .get();

                await _addContact(userDoc.id);
                close(context, userData);
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Enter a name to search', style: usernameStyle,));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('User')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')

          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: Loading());
        }
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;

            final String userName = userData['name'] ?? 'No Name';
            final String userEmail = userData['email'] ?? 'No Email';

            return ListTile(
              title: Text(userName, style: usernameStyle,),
              subtitle: Text(userEmail, style: emailStyle,),
              onTap: () async {
                final userExistNotPush = await firestore
                    .collection('User')
                    .where('name', isEqualTo: userName)
                    .get();

                await _addContact(userDoc.id);
                close(context, userData);
              },

            );
          },
        );
      },
    );
  }
}