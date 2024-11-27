import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/pages/admin/product_detail.dart';
import 'package:fyp/services/shoes_services.dart';

class ProductManagement extends StatelessWidget {
  // Reference to ShoeService
  final ShoeService _shoesService = ShoeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Shoe List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF161822),
      ),
      backgroundColor: Color(0xFF161822),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shoes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var shoes = snapshot.data!.docs;

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
                  subtitle: Text('Vendor: ${shoe['vendorUsername']}'),
                  trailing: IconButton(
                    onPressed: () async {
                      // Call the deleteShoe function from ShoeService
                      await _shoesService.deleteShoe(shoe.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Shoe deleted successfully')),
                      );
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                  onTap: () {
                    // Navigate to the shoe details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShoeDetailsPage(
                          shoeId: shoe.id, // Pass the shoe ID to the details page
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
