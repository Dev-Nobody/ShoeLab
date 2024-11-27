import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/pages/vendor/add_product.dart';
import 'package:fyp/services/shoes_services.dart';

class ProductPage extends StatelessWidget {
  final ShoeService _shoeService = ShoeService();

  @override
  Widget build(BuildContext context) {
    // Get the current user's email
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _shoeService.fetchShoes(userEmail),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var shoes = snapshot.data!;

          // Check if there are no products
          if (shoes.isEmpty) {
            return Center(
              child: Text(
                'No Products Added',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Confirm delete action
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Delete Product'),
                            content: Text('Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete) {
                        try {
                          await _shoeService.deleteShoe(shoe.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Product deleted successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete product')),
                          );
                        }
                      }
                    },
                  ),
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
