import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyp/pages/customer/change_password.dart';
import 'package:image_picker/image_picker.dart';

class AdminProfile extends StatefulWidget {
  AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  // Current logged in user
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Controllers for the editable fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String? _profileImageUrl;

  // Future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .get();
  }

  // Function to update user details in Firestore
  Future<void> _updateUserDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.email)
          .update({
        'username': _usernameController.text,
        'role': 'Admin',
        'profileImage': _profileImageUrl, // Update profile image URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile.')),
      );
    }
  }

  // Function to pick an image and upload to Firebase Storage
  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Show a loading indicator to provide feedback
        setState(() {
          // Optionally, show a loading indicator here
        });

        // Get the file path and read bytes asynchronously
        final file = File(image.path);
        final imageBytes = await file.readAsBytes();

        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('${currentUser!.email}/profile.jpg');
        await imageRef.putData(imageBytes);

        // Get the download URL of the uploaded image
        final imageUrl = await imageRef.getDownloadURL();

        setState(() {
          _profileImageUrl = imageUrl;
        });

        // Update Firestore with new image URL
        await _updateUserDetails();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Profile',style: TextStyle(color: Colors.white),),
        backgroundColor:  Color(0xFF161822),
      ),
      backgroundColor:  Color(0xFF161822),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // Loading..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Error
          else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // Data received
          else if (snapshot.hasData) {
            // Extract data
            Map<String, dynamic>? user = snapshot.data!.data();

            // Set initial values for text fields and profile image URL
            _usernameController.text = user?['username'] ?? '';
            _profileImageUrl = user?['profileImage'];

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('assets/images/admin.jpg') as ImageProvider,
                          child: _profileImageUrl == null
                              ? Icon(Icons.camera_alt, size: 40)
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateUserDetails,
                        child: Text('Update Profile'),
                      ),SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(),));
                        },
                        child: Text('Change Password'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Text('No Data');
          }
        },
      ),
    );
  }
}
