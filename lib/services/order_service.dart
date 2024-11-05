import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order in Firestore with the current user's ID
  Future<void> createOrder(List<Map<String, dynamic>> items, double totalPrice) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in");
      }

      String userId = user.email!;  // Get the current user's email
      DateTime now = DateTime.now();
      String formattedDate = "${now.day}-${now.month}-${now.year}";
      String formattedTime = "${now.hour}:${now.minute}:${now.second}";

      List<Map<String, dynamic>> orderItems = [];

      // Fetch vendor usernames for each item in the order
      for (var item in items) {
        String shoeName = item['shoeName'];
        QuerySnapshot shoeQuery = await _firestore.collection('shoes')
            .where('name', isEqualTo: shoeName)  // Adjust to match your data structure
            .get();

        if (shoeQuery.docs.isNotEmpty) {
          String vendorUsername = shoeQuery.docs.first['vendorUsername'];

          // Add item with vendorUsername to orderItems
          orderItems.add({
            'shoeName': shoeName,
            'shoeSize': item['selectedSize'],
            'quantity': item['quantity'],
            'customized': item['customized'] ?? false,
            'vendorUsername': vendorUsername,
          });
        } else {
          throw Exception("Shoe not found: $shoeName");
        }
      }

      // Prepare the order data
      Map<String, dynamic> orderData = {
        'userId': userId,
        'orderItems': orderItems,
        'totalPrice': totalPrice,
        'orderDate': formattedDate,
        'orderTime': formattedTime,
        'orderStatus': 'Pending',  // Default status as "Pending"
      };

      String orderId = _firestore.collection('orders').doc().id;  // Generates a unique ID

      // Save the order data to the orders collection and user's subcollection
      await _firestore.collection('orders').doc(orderId).set(orderData);
      await _firestore.collection('users').doc(user.email).collection('orders').doc(orderId).set(orderData);

      print("Order created successfully with status Pending!");
    } catch (e) {
      throw Exception("Failed to create order: $e");
    }
  }

  // Function to fetch orders based on userId
  Future<List<Map<String, dynamic>>> fetchOrdersByUserId(String userId) async {
    try {
      // Fetch orders where the userId matches the provided email
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();

      // Check if orders are found
      if (ordersSnapshot.docs.isEmpty) {
        return []; // Return an empty list if no orders are found
      }

      // Convert orders into a list of maps, including the Firestore document ID
      List<Map<String, dynamic>> orders = ordersSnapshot.docs.map((doc) {
        return {
          'orderId': doc.id, // Include the document ID
          ...doc.data() as Map<String, dynamic>, // Spread the document data
        };
      }).toList();

      return orders;
    } catch (e) {
      throw Exception("Failed to fetch orders for user $userId: $e");
    }
  }

  // Fetch orders for the currently logged-in user
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in");
      }

      // Get the user's orders from Firestore
      QuerySnapshot orderSnapshot = await _firestore
          .collection('orders')
          .get();

      // Check if orders exist for the user
      if (orderSnapshot.docs.isEmpty) {
        return [];
      }

      // Convert Firestore documents to a list of maps
      List<Map<String, dynamic>> orders = orderSnapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return orders;
    } catch (e) {
      throw Exception("Failed to fetch orders: $e");
    }
  }

  // Fetch a list of orders for the currently logged-in user
  Future<List<Map<String, dynamic>>> fetchAllUserOrders() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in");
      }

      String userId = user.email!;  // Get the current user's email
      print("Fetching all orders for user: $userId");

      // Fetch all orders from the user's orders subcollection
      QuerySnapshot userOrdersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();

      print("Total orders found: ${userOrdersSnapshot.docs.length}");

      // Check if there are orders
      if (userOrdersSnapshot.docs.isEmpty) {
        return [];  // Return an empty list if no orders are found
      }

      // Convert the orders to a list of maps, including the Firestore document ID
      List<Map<String, dynamic>> userOrders = userOrdersSnapshot.docs.map((doc) {
        print("Order data: ${doc.data()}");  // Debugging each order
        return {
          'orderId': doc.id,  // Add the document ID as 'orderId'
          ...doc.data() as Map<String, dynamic>,  // Include the rest of the order data
        };
      }).toList();

      return userOrders;  // Return the list of orders with document IDs
    } catch (e) {
      print("Error fetching user orders: $e");
      throw Exception("Failed to fetch user orders: $e");
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': newStatus,
      });
      print("Order status updated to $newStatus");
    } catch (e) {
      throw Exception("Failed to update order status: $e");
    }
  }
}
