import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shoe List'),
      ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

