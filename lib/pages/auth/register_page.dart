import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fyp/components/my_button.dart';
import 'package:fyp/components/my_textfield.dart';
import 'package:fyp/components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  String selectedRole = 'Customer'; // Default role is "Customer"
  String DefaultProfileImage = 'https://firebasestorage.googleapis.com/v0/b/shoelab-fyp-f73e3.appspot.com/o/usericon.png?alt=media&token=20aa357c-f2f9-468b-be36-c8acbe30349c'; // Default role is "Customer"

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Sign user up method
  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        //create user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //add User details
        addUserDetails(
          userNameController.text.trim(),
          emailController.text.trim(),
          phoneNumberController.text.trim(),
          addressController.text.trim(),
          selectedRole,
          DefaultProfileImage,
        );
      } else {
        Navigator.pop(context);
        showErrorMessage("Passwords don't match");
      }

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  Future addUserDetails(String username, String email, String phoneNumber,
      String address, String role, String profileImage) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.email).set({
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'role': role,
        'profileImage':profileImage
      });
    }
  }


  // Error message dialog
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Image.asset('lib/images/shoelab.png',
                      color: Colors.white),
                ),

                const SizedBox(height: 35),

                Column(
                  children: [
                    //username
                    MyTextfield(
                      controller: userNameController,
                      hintText: 'UserName',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    //Address
                    MyTextfield(
                      controller: addressController,
                      hintText: 'Address',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    //Phone number
                    MyTextfield(
                      controller: phoneNumberController,
                      hintText: 'PhoneNumber',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // email
                    MyTextfield(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // Password
                    MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // Confirm Password
                    MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // Role selection (Customer or Vendor)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Centers the row horizontally
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Customer',
                                style: TextStyle(color: Colors.white)),
                            value: 'Customer',
                            groupValue: selectedRole,
                            onChanged: (String? value) {
                              setState(() {
                                selectedRole = value!;
                              });
                            },
                            activeColor: Colors.cyanAccent,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Vendor',
                                style: TextStyle(color: Colors.white)),
                            value: 'Vendor',
                            groupValue: selectedRole,
                            onChanged: (String? value) {
                              setState(() {
                                selectedRole = value!;
                              });
                            },
                            activeColor: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 10),

                // Sign up button
                MyButton(
                  onTap: signUserUp,
                  text: 'Sign Up',
                ),

                //roles

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text('Login Now',
                            style: TextStyle(color: Colors.cyanAccent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}