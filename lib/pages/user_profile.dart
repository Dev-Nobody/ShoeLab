import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  //current logged in user
  User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.grey.shade500,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          //loading..
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }

          // error
          else if(snapshot.hasError){
            return Text('Error: ${snapshot.error}');
          }

          // data recived
          else if(snapshot.hasData){
            //extract data
            Map<String, dynamic>? user =snapshot.data!.data();

            return Center(
              child: Column(
                children: [
                  Text('Email : ${user!['email']}'),
                  Text('Address : ${user['address']}'),
                  Text(user['phoneNumber']),
                  Text(user['role']),
                  Text(user['username']),
                ],
              ),
            );
          }
          else{
            return Text(('No Data'));
          }
        },
      ),
    );
  }
}
