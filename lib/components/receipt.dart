import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyReceipt extends StatelessWidget {
  final List<Map<String, dynamic>> checkedItems;

  const MyReceipt({
    super.key,
    required this.checkedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 25, top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Thank you for your order!'),
            const SizedBox(
              height: 25,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(25),
              child: Text('Get Orderrr'),
              // Consumer<Cart>(
              //   builder: (context, cart, child) =>
              //       Text(cart.displayCartReceipt(checkedItems),style: TextStyle(color: Colors.white),),
              // ),
            ),
            const SizedBox(height: 25,),
            const Text('Estimated delivery time is 6-7 working days')
          ],
        ),
      ),
    );
  }
}
