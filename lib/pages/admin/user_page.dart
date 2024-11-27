import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;

  UserDetailsPage({required this.userId});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  // Controllers for the editable fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _profileImageUrl;

  // Function to fetch user details
  Future<DocumentSnapshot> fetchUserDetails() async {
    return await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
  }

  // Function to update user details in Firestore
  Future<void> _updateUserDetails() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'username': _usernameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'phoneNumber': _phoneController.text,
        'profileImage': _profileImageUrl, // Update profile image URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details updated successfully!')),
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
        final file = File(image.path);
        final imageBytes = await file.readAsBytes();

        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('${widget.userId}/profile.jpg');
        await imageRef.putData(imageBytes);

        // Get the download URL of the uploaded image
        final imageUrl = await imageRef.getDownloadURL();

        setState(() {
          _profileImageUrl = imageUrl;
        });

        // Update Firestore with the new image URL
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
        title: Center(child: Text('User Details',style: TextStyle(color: Colors.white),)),
        backgroundColor: Color(0xFF161822),
      ),
      backgroundColor: Color(0xFF161822),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found.'));
          } else {
            var user = snapshot.data!;
            _usernameController.text = user['username'];
            _emailController.text = user['email'];
            _addressController.text = user['address'];
            _phoneController.text = user['phoneNumber'];
            _profileImageUrl = user['profileImage'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : AssetImage('assets/images/default-profile.jpg') as ImageProvider,
                        child: _profileImageUrl == null
                            ? Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField('Username:', _usernameController),
                    _buildTextField('Email:', _emailController),
                    _buildTextField('Address:', _addressController),
                    _buildTextField('Phone Number:', _phoneController),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserDetails,
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Build text field for displaying and updating user data
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Username',
          labelStyle: TextStyle(color: Colors.white),  // White label text
          border: OutlineInputBorder(),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
