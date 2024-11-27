import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/my_textfield.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final usernameController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPasswordManually() async {
    try {
      // Step 1: Fetch user based on username (or phone number/email if applicable)
      String username = usernameController.text.trim();

      // Mock verification: Replace with your actual verification logic
      if (username != 'valid_username') {
        throw Exception('Invalid username. Please try again.');
      }

      // Step 2: Update password
      String newPassword = newPasswordController.text.trim();

      if (newPassword.isEmpty || newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters long.');
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password updated successfully!'),
            );
          },
        );
      } else {
        throw Exception('User is not authenticated. Please log in again.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.lightGreenAccent.shade100,
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your username to verify your account, and then reset your password.',
                style: TextStyle(
                  color: Colors.lightGreenAccent.shade100,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              MyTextfield(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyTextfield(
                controller: newPasswordController,
                hintText: 'New Password',
                obscureText: true,
              ),
              SizedBox(height: 10),
              MaterialButton(
                onPressed: resetPasswordManually,
                child: Text('Reset Password'),
                color: Colors.lightGreenAccent.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
