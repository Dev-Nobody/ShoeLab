import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoesByCategoryPage extends StatelessWidget {
  final String categoryId; // Pass the categoryId from the category document
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
        title: Text(categoryName), // Display the category name as the title
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shoes')
            .where('category', isEqualTo: categoryId) // Filter by categoryId
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

              return ListTile(
                leading: Image.network(
                  shoe['imagePath'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(shoe['name']),
                subtitle: Text('Rs. ${shoe['price']}'),
                onTap: () {
                  // You can navigate to the shoe detail page if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
