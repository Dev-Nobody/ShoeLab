import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/pages/vendor/add_product.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's email
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shoes')
            .where('vendorUsername', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var shoes = snapshot.data!.docs;

          // Check if there are no products
          if (shoes.isEmpty) {
            return Center(
              child: Text('No Products Added', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              var shoe = shoes[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: shoe['imagePath'] != null
                      ? Image.network(
                    shoe['imagePath'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 50),
                  title: Text(shoe['name']),
                  subtitle: Text('Rs.${shoe['price']}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
