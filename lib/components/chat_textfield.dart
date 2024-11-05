import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatTextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;

  const ChatTextfield({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration:
        InputDecoration(
          enabledBorder: OutlineInputBorder(
            // borderSide: BorderSide(color:  Colors.lightGreenAccent.shade100),
            borderRadius: BorderRadius.circular(35),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color:Colors.lightGreenAccent.shade100,),
            borderRadius: BorderRadius.circular(35),
          ),
          fillColor: Colors.black26,
          filled: true,
          hintText: hintText,

          hintStyle: TextStyle(color: Colors.lightGreenAccent.shade100),
        ),

        style: TextStyle(color: Colors.lightGreenAccent.shade100),
        obscureText: obscureText,
        controller: controller,
      ),
    );
  }
}
