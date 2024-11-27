import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/my_button.dart';
import 'package:fyp/components/my_textfield.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userNameController = TextEditingController();
  final addressController = ''; // Placeholder for address input

  String selectedRole = 'Customer';
  String defaultProfileImage =
      'https://firebasestorage.googleapis.com/v0/b/shoelab-fyp-f73e3.appspot.com/o/usericon.png?alt=media&token=20aa357c-f2f9-468b-be36-c8acbe30349c';

  // Variables for phone number
  String countryISOCode = 'US';
  String countryCode = '+1';
  String phoneNumber = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    // addressController.dispose();
    super.dispose();
  }

  void signUserUp() async {
    // Display loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Email validation
      String email = emailController.text.trim();
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;

      if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
        Navigator.pop(context); // Close loading dialog
        showErrorMessage("Invalid email format");
        return;
      }

      // Password and confirm password match validation
      if (password != confirmPassword) {
        Navigator.pop(context); // Close loading dialog
        showErrorMessage("Passwords don't match");
        return;
      }

      // Register user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      addUserDetails(
        userNameController.text.trim(),
        email,
        '$countryCode$phoneNumber',
        addressController,
        selectedRole,
        defaultProfileImage,
      );

      Navigator.pop(context); // Close loading dialog
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
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
        'profileImage': profileImage,
      });
    }
  }

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Image.asset('lib/images/shoelab.png', color: Colors.white),
                ),
                const SizedBox(height: 35),
                Column(
                  children: [
                    MyTextfield(
                      controller: userNameController,
                      hintText: 'UserName',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: IntlPhoneField(
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.lightGreenAccent.shade100),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightGreenAccent.shade100),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        initialCountryCode: 'US', // Default country
                        onChanged: (phone) {
                          setState(() {
                            countryISOCode = phone.countryISOCode!;
                            countryCode = phone.countryCode;
                            phoneNumber = phone.number;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Customer', style: TextStyle(color: Colors.white)),
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
                            title: const Text('Vendor', style: TextStyle(color: Colors.white)),
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
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MyButton(
                  onTap: signUserUp,
                  text: 'Sign Up',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text('Login Now', style: TextStyle(color: Colors.cyanAccent)),
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
