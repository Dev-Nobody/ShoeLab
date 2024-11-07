import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/my_size_box.dart';
import 'package:fyp/components/my_slider.dart';
import 'package:fyp/pages/customer/cart_page.dart';
import 'package:fyp/pages/customer/customize_page.dart';
import 'package:fyp/pages/customer/home_page.dart';

class ShoesPage extends StatefulWidget {
  final String shoeId; // Pass the shoeId instead of the model

  const ShoesPage({super.key, required this.shoeId});

  @override
  State<ShoesPage> createState() => _ShoesPageState();
}

class _ShoesPageState extends State<ShoesPage> {
  String? selectedSize;
  Map<String, dynamic>? shoeData;
  List<Map<String, dynamic>> cart = []; // Local cart list to store selected items

  // Fetch shoe data from Firestore
  Future<void> fetchShoeData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('shoes')
        .doc(widget.shoeId)
        .get();
    setState(() {
      shoeData = documentSnapshot.data() as Map<String, dynamic>;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchShoeData();
  }

  void addShoeToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (selectedSize != null && shoeData != null && user != null) {
      // Prepare cart item data
      Map<String, dynamic> cartItem = {
        'shoeId': widget.shoeId,
        'shoeName': shoeData!['name'],
        'price': shoeData!['price'],
        'selectedSize': selectedSize,
        'vendorUsername': shoeData!['vendorUsername'],
        'customized': false,
        'addedAt': Timestamp.now(),
        'imagePath': shoeData!['imagePath'],
        'quantity': 1,
        'checked':false,
      };

      // Check if the shoe with the selected size is already in the cart
      QuerySnapshot existingItem = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('cart')
          .where('shoeId', isEqualTo: widget.shoeId)
          .where('selectedSize', isEqualTo: selectedSize)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // If it exists, update the quantity
        String cartItemId = existingItem.docs.first.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .collection('cart')
            .doc(cartItemId)
            .update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        // Add new cart item
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .collection('cart')
            .add(cartItem);
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.lightGreenAccent.shade100,
          title: const Text('Successfully Added!'),
          content: const Text('Check your cart'),
        ),
      );
    } else {
      // Show alert if no size is selected
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.lightGreenAccent.shade100,
          title: const Text('Select any Size'),
          content: const Text('Please select a size to continue.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shoeData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey.shade500,
          ),
        ),
        title: Center(
          child: Text(
            shoeData!['name'], // Fetch name from Firestore
            style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 26),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(selectedIndex: 2,),));
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.grey.shade500,
            ),
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 35.0),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        shoeData!['brand'].toUpperCase(), // Fetch brand
                        style: TextStyle(
                          color: Colors.lightGreenAccent.shade100,
                          fontSize: 150,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'lib/images/shoeBox.png',
                  width: 280,
                ),
              ],
            ),

            // Real body
            Column(
              children: [
                // First container (Sizes, Price, Image, buttons)
                Expanded(
                  flex: 9,
                  child: Row(
                    children: [
                      // Left column having Size & Price
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 80,
                            ),
                            // Size text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Size',
                                  style: TextStyle(
                                    color: Colors.lightGreenAccent.shade100,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.question_circle,
                                  color: Colors.lightGreenAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Sizes from Firestore
                            Expanded(
                              child: ListView.builder(
                                itemCount: shoeData!['sizes'].length,
                                itemBuilder: (context, index) {
                                  String size =
                                  shoeData!['sizes'][index].toString();
                                  return MySizeBox(
                                    size: size,
                                    isSelected: selectedSize == size,
                                    onTap: () {
                                      setState(() {
                                        selectedSize = size;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Price
                            Text(
                              'Rs. ${shoeData!['price']}',
                              style: TextStyle(
                                color: Colors.lightGreenAccent.shade100,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),

                      // Middle column for image and Add to Cart button
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Shoe Image from Firestore
                            Image.network(
                              shoeData!['imagePath'], // Fetch image URL
                              width: 220,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            // Add to Cart Button
                            MySlider(performAction: addShoeToCart),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),

                      // Right column for Favourite & Customize buttons
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 100,
                            ),
                            // Favourite Button
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            // Customize Button
                            RotatedBox(
                              quarterTurns: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomizePage(),));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Customize Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Second container to take space
                const Expanded(flex: 1, child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
