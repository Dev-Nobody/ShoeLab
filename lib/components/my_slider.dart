import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_to_act/slide_to_act.dart';

class MySlider extends StatelessWidget {
  void Function()? performAction;

  MySlider({super.key, required this.performAction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 65,
      child: RotatedBox(
        quarterTurns: 1,
        child: SlideAction(
          // borderRadius: 25,
          elevation: 0,
          innerColor: Colors.grey.shade800,
          outerColor: Colors.grey.shade800,
          submittedIcon: Transform.rotate(
              angle: 4.7,
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 35,
              )),
          sliderButtonIcon: Transform.rotate(
            angle: 4.7,
            child: Icon(
              Icons.shopping_bag,
              color: Colors.lightGreenAccent.shade100,
              size: 35,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 45),
            child: Lottie.asset('lib/animations/arrow.json', height: 30),
          ),
          onSubmit: () {
            performAction!();
          },
        ),
      ),
    );
  }
}
