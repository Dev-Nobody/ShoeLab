import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/pages/customer/shoes_page.dart'; // Import your ShoesPage here

class ShoesByCategoryPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ShoesByCategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shoes')
            .where('category', isEqualTo: categoryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No shoes found in this category.'));
          }

          final shoes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              final shoeId = shoe.id;

              return GestureDetector(
                onTap: () {
                  // Navigate to ShoesPage, passing the shoeId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoesPage(shoeId: shoeId),
                    ),
                  );
                },
                child: ListTile(
                  leading: Image.network(
                    shoe['imagePath'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(shoe['name']),
                  subtitle: Text('Rs. ${shoe['price']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
