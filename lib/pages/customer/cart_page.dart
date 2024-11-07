import 'package:flutter/material.dart';
import 'package:fyp/components/cart_items.dart';
import 'package:fyp/components/my_button.dart';
import 'package:fyp/pages/customer/payment_page.dart';
import 'package:fyp/services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> cartItems = [];
  List<bool> isCheckedList = [];
  bool isLoading = true;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    cartItems = await _cartService.fetchCartItems();
    isCheckedList = await _cartService.getCheckedList();
    setState(() {
      isLoading = false;
      totalPrice = _cartService
          .calculateTotalPrice(cartItems); // Calculate total on fetch
    });
  }

  Future<void> addQuantity(String itemId, int index) async {
    await _cartService.addQuantity(itemId);
    setState(() {
      cartItems[index]['quantity']++;
      totalPrice =
          _cartService.calculateTotalPrice(cartItems); // Recalculate total
    });
  }

  Future<void> subQuantity(
      String itemId, int index, int currentQuantity) async {
    await _cartService.subQuantity(itemId, currentQuantity);
    setState(() {
      fetchCartItems();
      totalPrice = _cartService.calculateTotalPrice(cartItems);
      cartItems[index]['quantity']--;
    });
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice = _cartService.calculateTotalPrice(cartItems);
    });
  }

  Future<List<Map<String, dynamic>>> fetchCheckedItems() async {
    return await _cartService.fetchCheckedItems();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                // Select All Checkbox
                Checkbox(
                  value: _cartService.getCheckedListState().isNotEmpty &&
                      _cartService
                          .getCheckedListState()
                          .every((checked) => checked),
                  activeColor: Colors.lightGreenAccent.shade100,
                  checkColor: Colors.grey.shade900,
                  onChanged: (value) async {
                    await _cartService.toggleSelectAll();
                    setState(() {
                      fetchCartItems(); // Refresh cart items to reflect the changes
                    });
                  },
                ),
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightGreenAccent,
                  ),
                ),
                const Spacer(),
                // Delete Icon to clear the cart
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _cartService.clearCart();
                    setState(() {
                      fetchCartItems(); // Refresh the UI after clearing the cart
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cartItems.isEmpty
                      ? const Center(
                          child: Text('Your cart is empty.',
                              style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = cartItems[index];
                            final cartItemId = cartItem['id'];
                            final currentQuantity = cartItem['quantity'];

                            return ListTile(
                              leading: SizedBox(
                                width: 20,
                                child: Checkbox(
                                  activeColor: Colors.lightGreenAccent.shade100,
                                  checkColor: Colors.grey.shade900,
                                  value: isCheckedList[index],
                                  onChanged: (newBool) {
                                    setState(() {
                                      _cartService.updateCheckedState(
                                          index,
                                          newBool!,
                                          cartItemId); // Update the checked state
                                      updateTotalPrice(); // Update total price when checkbox state changes
                                    });
                                  },
                                ),
                              ),
                              title: CartItems(
                                cartItem: cartItem,
                                addQuantity: () {
                                  addQuantity(cartItemId, index);
                                },
                                subQuantity: () {
                                  subQuantity(
                                      cartItemId, index, currentQuantity);
                                },
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Price: Rs.${totalPrice.toStringAsFixed(2)}',
                // Display total price
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.lightGreenAccent.shade100)),
                  child: TextButton(
                      onPressed: () async {},
                      child: Text(
                        'CheckOut',
                        style: TextStyle(color: Colors.lightGreenAccent.shade100),
                      ))),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: MyButton(
            //       onTap: () async {
            //         List<Map<String, dynamic>> checkedItems =
            //             await fetchCheckedItems(); // Fetch checked items from Firestore
            //
            //         if (checkedItems.isNotEmpty) {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) =>
            //                   PaymentPage(checkedItems: checkedItems),
            //             ),
            //           );
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(
            //                 content: Text('No items selected to proceed.')),
            //           );
            //         }
            //       },
            //       text: 'CheckOut'),
            // ),
          ],
        ),
      ),
    );
  }
}
