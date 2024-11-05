import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _categoryNameController = TextEditingController();
  File? _imageFile;

  // Function to add or update a category
  Future<void> _saveCategory(String name, {File? imageFile, String? docId}) async {
    try {
      String? imageUrl;

      // If an image is provided, upload it to Firebase Storage
      if (imageFile != null) {
        String fileName = 'categories/${DateTime.now().millisecondsSinceEpoch.toString()}';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // If updating an existing category
      if (docId != null) {
        final docRef = FirebaseFirestore.instance.collection('categories').doc(docId);
        final dataToUpdate = <String, dynamic>{'name': name};
        if (imageUrl != null) {
          dataToUpdate['image'] = imageUrl;
        }
        await docRef.update(dataToUpdate);
      } else {
        // If adding a new category
        await FirebaseFirestore.instance.collection('categories').add({
          'name': name,
          'image': imageUrl,
        });
      }
    } catch (e) {
      print('Error saving category: $e');
    }
  }

  // Function to delete a category
  Future<void> _deleteCategory(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  // Function to open the "Add/Update Category" dialog
  void _showCategoryDialog({String? docId, String? currentName, String? currentImageUrl}) {
    if (docId != null) {
      _categoryNameController.text = currentName ?? '';
    } else {
      _categoryNameController.clear();
      _imageFile = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId != null ? 'Update Category' : 'Add Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(labelText: 'Category Name'),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      setState(() {
                        _imageFile = File(pickedImage.path);
                      });
                    }
                  },
                  child: _imageFile == null
                      ? currentImageUrl != null
                      ? Image.network(
                    currentImageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.camera_alt),
                  )
                      : Image.file(
                    _imageFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  _saveCategory(
                    _categoryNameController.text,
                    imageFile: _imageFile,
                    docId: docId,
                  );
                  Navigator.of(context).pop();
                } else {
                  // Handle validation error (e.g., show an error message)
                }
              },
              child: Text(docId != null ? 'Update' : 'Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _categoryNameController.clear();
                _imageFile = null;
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        backgroundColor: Colors.grey.shade500,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No categories found.'));
          }
          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      child: ListTile(
                        tileColor: Colors.grey.shade200,
                        leading: Image.network(
                          category['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(category['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.edit),
                            //   onPressed: () => _showCategoryDialog(
                            //     docId: category.id,
                            //     currentName: category['name'],
                            //     currentImageUrl: category['image'],
                            //   ),
                            // ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteCategory(category.id);
                              },
                            ),
                          ],
                        ),
                      ),
                      onTap: () => _showCategoryDialog(
                        docId: category.id,
                        currentName: category['name'],
                        currentImageUrl: category['image'],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.grey.shade500,
      ),
    );
  }
}
