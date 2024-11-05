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
    return Container(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // height: 60,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                ),

                child: Icon(
                  icon,
                  size: 40,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,

                ),
                  textAlign: TextAlign.center,
                  softWrap: true,  // This ensures that the text will wrap onto the next line
                  overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
