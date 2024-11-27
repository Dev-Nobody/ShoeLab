import 'package:flutter/material.dart';

class OrdersButtons extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const OrdersButtons({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center( // Wrap with Center widget for centering horizontally
      child: Container(
        width: 100,
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Aligns content to the top
              crossAxisAlignment: CrossAxisAlignment.center, // Centers items horizontally
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
