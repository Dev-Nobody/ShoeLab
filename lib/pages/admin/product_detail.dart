import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShoeDetailsPage extends StatefulWidget {
  final String shoeId;

  ShoeDetailsPage({required this.shoeId});

  @override
  _ShoeDetailsPageState createState() => _ShoeDetailsPageState();
}

class _ShoeDetailsPageState extends State<ShoeDetailsPage> {
  // Controllers for the editable fields
  final TextEditingController _shoeNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  String? _categoryId;

  // Function to fetch shoe details
  Future<DocumentSnapshot> fetchShoeDetails() async {
    return await FirebaseFirestore.instance.collection('shoes').doc(widget.shoeId).get();
  }

  // Function to update shoe details in Firestore
  Future<void> _updateShoeDetails() async {
    try {
      await FirebaseFirestore.instance.collection('shoes').doc(widget.shoeId).update({
        'name': _shoeNameController.text,
        'brand': _brandController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'vendorUsername': _vendorController.text,
        'category': _categoryId, // Update the category if changed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shoe details updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating shoe details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating shoe details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Shoe Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF161822),
      ),
      backgroundColor: Color(0xFF161822),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchShoeDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Shoe not found.'));
          } else {
            var shoe = snapshot.data!;
            _shoeNameController.text = shoe['name'];
            _brandController.text = shoe['brand'];
            _priceController.text = shoe['price'].toString();
            _descriptionController.text = shoe['description'];
            _vendorController.text = shoe['vendorUsername'];
            _categoryId = shoe['category'];

            var sizes = List<String>.from(shoe['sizes'] ?? []);
            var categoryId = shoe['category'] ?? ''; // Category ID

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    shoe['imagePath'] != null
                        ? Image.network(shoe['imagePath'])
                        : Icon(Icons.image, size: 150),
                    SizedBox(height: 20),
                    _buildTextField('Shoe Name:', _shoeNameController),
                    _buildTextField('Brand:', _brandController),
                    _buildTextField('Price:', _priceController),
                    _buildTextField('Description:', _descriptionController),
                    _buildTextField('Vendor:', _vendorController),
                    // You could include category update functionality here if needed
                    _buildTextField('Category ID:', TextEditingController(text: _categoryId)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateShoeDetails,
                      child: Text('Update Shoe Details'),
                    ),
                    SizedBox(height: 20),
                    _buildSizeSelection(sizes),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to build text fields for shoe details
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Helper method to display shoe sizes as checkboxes or buttons
  Widget _buildSizeSelection(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Sizes:',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sizes.map((size) {
            return ChoiceChip(
              label: Text(size),
              selected: false, // You can manage selection state if needed
              onSelected: (selected) {},
              backgroundColor: Colors.grey,
              selectedColor: Colors.blue,
            );
          }).toList(),
        ),
      ],
    );
  }
}
