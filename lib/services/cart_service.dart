import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<bool> _isCheckedList = [];

  // Add this method to expose _isCheckedList
  List<bool> getCheckedListState() {
    return _isCheckedList;
  }


  // Fetch cart items for the current user and initialize the checked state list
  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    List<Map<String, dynamic>> cartItems = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.email) // Use user email as document ID
          .collection('cart')
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> cartItem = doc.data() as Map<String, dynamic>;
        cartItem['id'] = doc.id; // Include the document ID
        cartItems.add(cartItem);
      }

      // Initialize checked state list to false for all items
      // _isCheckedList = List<bool>.filled(cartItems.length, false);
      _isCheckedList = List<bool>.generate(cartItems.length, (index) {
        return cartItems[index]['checked'] ?? false; // Initialize checked state
      });

    } catch (e) {
      print("Error fetching cart items: $e");
    }
    return cartItems;
  }

  //Method for Removing items
  Future<void> removeItemFromCart(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.email)
          .collection('cart')
          .doc(itemId)
          .delete();
      await fetchCartItems();
    } catch (e) {
      print("Error removing item from cart: $e");
    }
  }

  // Method to clear all items from the cart
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get all cart item documents for the user
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.email)
          .collection('cart')
          .get();

      // Delete each document in the cart
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print("All items cleared from cart");
    } catch (e) {
      print("Error clearing cart: $e");
    }
  }

//___________ C H E C K __ F U N C T I O N S__________

  // Method to get the checked state list
  Future<List<bool>> getCheckedList() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    List<bool> isCheckedList = [];

    try {
      // Fetch the cart items for the current user
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.email) // Use user email as document ID
          .collection('cart')
          .get();

      for (var doc in querySnapshot.docs) {
        // Assuming each cart item has a 'checked' field, retrieve it
        bool isChecked = doc['checked'] ?? false; // Default to false if 'checked' doesn't exist
        isCheckedList.add(isChecked);
      }

    } catch (e) {
      print("Error fetching checked state from Firestore: $e");
    }

    // Update the local _isCheckedList with the fetched values
    _isCheckedList = isCheckedList;

    return isCheckedList;
  }

  // Method to update the checked state of an item
  Future<void> updateCheckedState(int index, bool value, String cartItemId) async {
    _isCheckedList[index] = value;

    // Update checked state in Firestore
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.email)
            .collection('cart')
            .doc(cartItemId)
            .update({'checked': value});
      } catch (e) {
        print("Error updating checked state: $e");
      }
    }
  }

  // Method to toggle the checked state of all cart items
  Future<void> toggleSelectAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if all items are currently selected
    bool allSelected = _isCheckedList.every((isChecked) => isChecked);

    try {
      // Fetch the user's cart items
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.email) // Use user email as document ID
          .collection('cart')
          .get();

      // Loop through each cart item and toggle the 'checked' state
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'checked': !allSelected}); // Toggle to the opposite state
      }

      // Update local state (_isCheckedList)
      _isCheckedList = List<bool>.filled(_isCheckedList.length, !allSelected);

      print("All items have been ${allSelected ? 'unchecked' : 'checked'}");
    } catch (e) {
      print("Error toggling select all: $e");
    }
  }

  // for local
  List<Map<String, dynamic>> getCheckedItems(List<Map<String, dynamic>> cartItems) {
    List<Map<String, dynamic>> checkedItems = [];

    for (int i = 0; i < cartItems.length; i++) {
      if (_isCheckedList[i]) {
        checkedItems.add(cartItems[i]);
      }
    }

    return checkedItems;
  }

  // for remote
  Future<List<Map<String, dynamic>>> fetchCheckedItems() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    List<Map<String, dynamic>> checkedItems = [];

    try {
      // Query Firestore for items where 'checked' is true for the current user
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.email)
          .collection('cart')
          .where('checked', isEqualTo: true) // Only fetch items where checked is true
          .get();

      // Convert the Firestore documents into a list of Maps
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> cartItem = doc.data() as Map<String, dynamic>;
        cartItem['id'] = doc.id; // Include document ID
        checkedItems.add(cartItem);
      }
    } catch (e) {
      print("Error fetching checked items: $e");
    }

    return checkedItems;
  }


  //___________C A L C U L A T I O N____________________

  // Method to calculate the total price of checked items
  double calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double totalPrice = 0.0;

    for (int i = 0; i < cartItems.length; i++) {
      if (_isCheckedList[i]) {
        int quantity = cartItems[i]['quantity'];
        double price = cartItems[i]['price']; // Assuming 'price' is a key in your cart item
        totalPrice += quantity * price;
      }
    }

    return totalPrice;
  }

  // Method to calculate the total price of checked items
  Future<double> calculateTotalCheckedItemsPrice() async {
    double totalPrice = 0.0;

    // Fetch checked items
    List<Map<String, dynamic>> checkedItems = await fetchCheckedItems();

    // Iterate over the checked items and calculate the total price
    for (var item in checkedItems) {
      int quantity = item['quantity'];
      double price = item['price']; // Assuming 'price' is a key in your cart item
      totalPrice += quantity * price;
    }

    return totalPrice;
  }


  //________Q U A N T I T Y_____________________________

  // methods for adding
  Future<void> addQuantity(String cartItemId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.email!)
            .collection('cart')
            .doc(cartItemId)
            .update({
          'quantity': FieldValue.increment(1),
        });
        print("Quantity increased for item ID: $cartItemId");
      } catch (e) {
        print("Error adding quantity: $e");
      }
    }
  }

  // Subtract quantity from the cart item,
  Future<void>  subQuantity(String cartItemId, int currentQuantity) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        if (currentQuantity > 1) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .collection('cart')
              .doc(cartItemId)
              .update({
            'quantity': FieldValue.increment(-1),
          });
          print("Quantity decreased for item ID: $cartItemId");
        } else {
          removeItemFromCart(cartItemId);
        }
      } catch (e) {
        print("Error subtracting quantity: $e");
      }
    }
  }


}

//Cart Service and Cart Operation have only two function/problems left to solve
//1)toggle select all
//2)refresh ui after clearing cart
// both problems exist in homepage App Bar
