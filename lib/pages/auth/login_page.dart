import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/my_button.dart';
import 'package:fyp/components/my_textfield.dart';
import 'package:fyp/components/square_tile.dart';
import 'package:fyp/pages/auth/forget_password_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void SignUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      //pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);

      //show error Message
      ShowErrorMessage(e.code);
    }
  }

//error message to user
  void ShowErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        );
      },
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
                const SizedBox(
                  height: 70,
                ),

                //logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Image.asset(
                    'lib/images/shoelab.png',
                    color: Colors.lightGreenAccent.shade100,
                  ),
                ),

                const SizedBox(
                  height: 100,
                ),

                //username
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(
                  height: 25,
                ),

                //password
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(
                  height: 10,
                ),

                //Forget password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder:(context) {
                            return ForgetPasswordPage();
                          },));
                        },
                        child: const Text(
                          'Forget password?',
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //sign in Button
                MyButton(
                  onTap: SignUserIn,
                  text: 'Sign In',
                ),

                const SizedBox(
                  height: 15,
                ),

                //Or Continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          )),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                //other methods
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(ImagePath: 'lib/images/apple.png'),
                    SizedBox(
                      width: 25,
                    ),
                    SquareTile(ImagePath: 'lib/images/google.png'),

                    SizedBox(
                      width: 25,
                    ),
                    // GestureDetector(
                    //   onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => AdminPage(),)),
                    //     child: SquareTile(ImagePath: 'lib/images/google.png')),
                  ],
                ),

                //Not Registered yet
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Register Now,',
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}