import 'package:flutter/material.dart';
import 'package:fyp/services/content_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final ContentService _contentService = ContentService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  // Method to pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Method to call ContentService's addContent
  Future<void> _uploadContent() async {
    try {
      await _contentService.addContent(
        titleController.text,
        descriptionController.text,
        _image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Content uploaded successfully!')),
      );

      // Clear fields after uploading
      titleController.clear();
      descriptionController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload content: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Content"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: Icon(Icons.add_a_photo),
              )
                  : Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadContent,
              child: Text("Upload Content"),
            ),
          ],
        ),
      ),
    );
  }
}
