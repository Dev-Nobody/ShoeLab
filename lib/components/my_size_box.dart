import 'package:flutter/material.dart';

class MySizeBox extends StatelessWidget {
  final String size;
  final bool isSelected;
  void Function()? onTap;

  MySizeBox({
    super.key,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.lightGreenAccent.shade100
                : Colors.transparent,
            border: Border.all(
              color: Colors.lightGreenAccent.shade100,
            ),
          ),
          width: 40,
          height: 40,
          // color: Colors.white,
          child: Center(
            child: Text(
              size,
              style: TextStyle(
                color: isSelected
                    ? Colors.grey.shade900
                    : Colors.lightGreenAccent.shade100,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
