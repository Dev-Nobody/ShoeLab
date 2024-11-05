import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  String selectedCategory = '';
  List<String> sizes = [];
  int quantity = 1;
  File? _image;
  String? _imageUrl;
  String? vendorUsername;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Retrieve the vendor username (email in this case) from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      vendorUsername = user.email;// Assuming the username is the email
      return print('Vendor naem is :   ${vendorUsername}');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    brandController.dispose();
    sizeController.dispose();
    super.dispose();
  }

  void addSize() {
    if (sizeController.text.isNotEmpty) {
      setState(() {
        sizes.add(sizeController.text);
        sizeController.clear();
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      _imageUrl = await snapshot.ref.getDownloadURL();
    }
  }

  Future<void> addProduct() async {
    // Ensure vendorUsername is set before proceeding
    if (vendorUsername == null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        vendorUsername = user.email; // Assuming the username is the email
      }
    }

    // Check if vendorUsername is still null
    if (vendorUsername == null) {
      print("Error: Vendor username is null");
      return; // Stop the function execution
    }

    await uploadImage();

    // Create a new shoe document with vendor username
    await FirebaseFirestore.instance.collection('shoes').add({
      'name': nameController.text,
      'price': double.parse(priceController.text),
      'imagePath': _imageUrl,
      'description': descriptionController.text,
      'brand': brandController.text,
      'quantity': quantity,
      'sizes': sizes,
      'category': selectedCategory, // Store category ID or name
      'vendorUsername': vendorUsername, // Store the vendor username
    });

    // Clear the form after submission
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    brandController.clear();
    sizeController.clear();
    setState(() {
      sizes.clear();
      selectedCategory = '';
      quantity = 1;
      _image = null;
      _imageUrl = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: _image != null
                    ? Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: brandController,
                decoration: InputDecoration(labelText: 'Brand'),
              ),
              Row(
                children: [
                  Text('Quantity: $quantity'),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),
                ],
              ),
              TextField(
                controller: sizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Size',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: addSize,
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: sizes.map((size) {
                  return Chip(
                    label: Text(size),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<DropdownMenuItem<String>> categoryItems = snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList();

                  return DropdownButton<String>(
                    value: selectedCategory.isNotEmpty ? selectedCategory : null,
                    hint: Text('Select Category'),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: categoryItems,
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
