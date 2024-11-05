import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fyp/services/feedback_service.dart';
import 'package:fyp/services/order_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewPage extends StatefulWidget {
  final String orderId;

  const ReviewPage({super.key, required this.orderId});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _reviewController = TextEditingController();

  final FeedbackService _feedbackService = FeedbackService();
  final OrderService _orderService = OrderService();
  String? _vendorName; // To store the fetched vendorName

  @override
  void initState() {
    super.initState();
    // _fetchVendorName(); // Fetch vendor name when the page is loaded
  }

  // Fetch vendor name using orderId
  // Future<void> _fetchVendorName() async {
  //   String? vendorName = await _feedbackService.fetchVendorUsernamesFromOrder(widget.orderId);
  //   setState(() {
  //     _vendorName = vendorName;
  //     print('vendor nameeeeeeeeeeeeeeeeeeee:${_vendorName}');
  //   });
  // }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReview() async {
    final User? user = FirebaseAuth.instance.currentUser; // Get current user

    if (user != null) {
      if (_rating == 0) {
        // Prevent submission if no rating is provided
        print("Please provide a rating.");
        return;
      }

      if (_reviewController.text.isEmpty) {
        // Prevent submission if no review message is provided
        print("Please write a review.");
        return;
      }

      String customerId = user.email!;
      String? imageUrl;

      // If an image was picked, upload it to Firebase Storage
      if (_imageFile != null) {
        try {
          // Define the storage reference
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('review_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

          // Upload the image file
          UploadTask uploadTask = storageRef.putFile(_imageFile!);
          TaskSnapshot taskSnapshot = await uploadTask;

          // Get the download URL of the uploaded image
          imageUrl = await taskSnapshot.ref.getDownloadURL();
        } catch (e) {
          print("Error uploading image: $e");
          return; // Stop the submission if image upload fails
        }
      }

      try {
        await _feedbackService.createReview(
          orderId: widget.orderId,
          customerId: customerId,
          stars: _rating.round(), // Convert double to int by rounding
          message: _reviewController.text,
          imageUrl: imageUrl, // Pass the image URL if uploaded, null if not
        );

        await _orderService.updateOrderStatus(widget.orderId, "Reviewed");


        print("Review submitted successfully.");
        Navigator.of(context).pop(); // Go back after successful submission
      } catch (e) {
        print("Error submitting review: $e");
      }
    } else {
      print("User not logged in.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Review Order ID: ${widget.orderId}"),
            if (_vendorName != null)
              Text("Vendor Name: $_vendorName"), // Show vendor name if available
            const SizedBox(height: 20),

            // Star rating widget
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),

            // Review text field
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // Image upload section
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                _imageFile != null
                    ? Image.file(
                  _imageFile!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : const Text("No image selected"),
              ],
            ),
            const Spacer(),

            // Submit button
            ElevatedButton(

              onPressed: () {
                _submitReview();
              }, // Call the submit function
              child: const Text("Submit Review"),
            ),
          ],
        ),
      ),
    );
  }
}
