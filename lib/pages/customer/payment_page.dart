import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fyp/components/my_button.dart';
import 'package:fyp/pages/customer/delivery_progress_page.dart';
import 'package:fyp/services/cart_service.dart';
import 'package:fyp/services/order_service.dart';  // Import OrderService

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> checkedItems;

  const PaymentPage({super.key, required this.checkedItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = "";
  String expiryDate = "";
  String cardHolderName = "";
  String cvvCode = "";
  bool showBackView = false;
  CartService cartService = CartService();  // CartService instance
  OrderService orderService = OrderService(); // OrderService instance

  Future<void> userTappedPay() async {
    if (formKey.currentState!.validate()) {
      // Fetch the checked items
      List<Map<String, dynamic>> checkedItems = widget.checkedItems;

      if (checkedItems.isNotEmpty) {
        // Await the total price calculation
        double totalPrice = await cartService.calculateTotalCheckedItemsPrice(); // Await the result
        print("Total Price: $totalPrice");

        // Show confirmation dialog
        bool? confirmation = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Payment'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Card Number: $cardNumber'),
                  Text('Expiry Date: $expiryDate'),
                  Text('Card Holder Name: $cardHolderName'),
                  Text('CVV: $cvvCode'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (confirmation == true) {
          // Create the order if confirmed
          await orderService.createOrder(checkedItems, totalPrice);

          // Remove checked items from the cart after placing order
          for (var item in checkedItems) {
            await cartService.removeItemFromCart(item['id']);
          }

          // Navigate to the delivery progress page or show a success message
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeliveryProgressPage(checkedItems: checkedItems)),
          );
        }
      } else {
        // Show a message if no items are selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items selected for payment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: showBackView,
              onCreditCardWidgetChange: (p0) {},
              enableFloatingCard: true,
              glassmorphismConfig: Glassmorphism.defaultConfig(),
            ),
            CreditCardForm(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: (data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cardHolderName = data.cardHolderName;
                  cvvCode = data.cvvCode;
                });
              },
              formKey: formKey,
            ),
            MyButton(onTap: userTappedPay, text: 'Pay Now'),
          ],
        ),
      ),
    );
  }
}
