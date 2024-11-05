import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/my_textfield.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(context: context, builder:(context) {
        return AlertDialog(
          content: Text('Password Reset link sent! check your email') ,
        );
      },);
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(context: context, builder:(context) {
        return AlertDialog(
          content: Text(e.message.toString()) ,
        );
      },);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter Your Email and we will send you reset login link',
              style: TextStyle(
                color: Colors.lightGreenAccent.shade100,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          MyTextfield(
            controller: emailController,
            hintText: 'Email',
            obscureText: false,
          ),
          SizedBox(
            height: 10,
          ),
          MaterialButton(
            onPressed: passwordReset,
            child: Text('Reset password'),
            color: Colors.lightGreenAccent.shade100,
          )
        ],
      ),
    );
  }
}
