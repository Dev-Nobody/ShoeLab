import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/pages/customer/shoes_page.dart';

class ShoeListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('shoes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No shoes found.'));
        }

        final shoes = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true, // Ensures the GridView doesn't take up infinite height
          physics: const NeverScrollableScrollPhysics(), // Prevents scrolling, if needed
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 3 / 4, // Adjust ratio to make the cards fit better
          ),
          itemCount: shoes.length,
          itemBuilder: (context, index) {
            final shoe = shoes[index];
            final shoeId = shoe.id; // Get shoeId from Firestore

            return GestureDetector(
              onTap: () {
                // Navigate to ShoesPage on tap, passing the shoeId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoesPage(shoeId: shoeId),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Name
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0, top: 20),
                                  child: Text(
                                    shoe['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                // Background logo (Category name in uppercase)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                                  child: Text(
                                    shoe['name'].toString().toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Category Image
                    Positioned(
                      top: 55,
                      right: 0,
                      child: Image.network(
                        shoe['imagePath'],
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
