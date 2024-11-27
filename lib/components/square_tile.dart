import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String ImagePath;
  final Function()? onTap;

  const SquareTile({
    super.key,

    required this.ImagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(50),
          color: Colors.lightGreenAccent.shade100,
        ),
        child: Image.asset(
          ImagePath,
          height: 30,
          // color: Colors.black,
        ),
      ),
    );
  }
}
