import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VendorProfile extends StatefulWidget {
  VendorProfile({super.key});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Controllers for user details
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _profileImage;

  // Fetch user details
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
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'address': _addressController.text,
        'profileImage': _profileImage,
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

  // Function to pick and upload image
  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final file = File(image.path);
        final imageBytes = await file.readAsBytes();

        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('${currentUser!.email}/profile.jpg');
        await imageRef.putData(imageBytes);

        final imageUrl = await imageRef.getDownloadURL();

        setState(() {
          _profileImage = imageUrl;
        });

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
        title: Text('Profile'),
        backgroundColor: Colors.grey.shade500,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();

            // Set initial values
            _usernameController.text = user?['username'] ?? '';
            _emailController.text = user?['email'] ?? '';
            _phoneNumberController.text = user?['phoneNumber'] ?? '';
            _addressController.text = user?['address'] ?? '';
            _profileImage = user?['profileImage'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _profileImage != null
                            ? NetworkImage(_profileImage!)
                            : AssetImage('images/user.jpg') as ImageProvider,
                        child: _profileImage == null
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
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixText: '+1 ', // Default country code (can be customized)
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserDetails,
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No Data'));
          }
        },
      ),
    );
  }
}
