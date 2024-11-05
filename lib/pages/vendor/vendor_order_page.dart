import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/services/order_service.dart';

class VendorOrderPage extends StatefulWidget {
  const VendorOrderPage({super.key});

  @override
  State<VendorOrderPage> createState() => _VendorOrderPageState();
}

class _VendorOrderPageState extends State<VendorOrderPage>
    with SingleTickerProviderStateMixin {
  OrderService _orderService = OrderService(); // Create an instance of OrderService
  late Future<List<Map<String, dynamic>>> _ordersFuture; // Store the future
  String? _currentUserEmail; // Variable to store the current user's email
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail(); // Get the current user's email on init
    _ordersFuture = _orderService.fetchOrders(); // Fetch the orders on init
    _tabController = TabController(length: 4, vsync: this);
  }

  // Get the current logged-in user's email using FirebaseAuth
  void _getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserEmail = user.email; // Set the current user's email
      });
    }
  }

  // Function to update the order status
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      setState(() {
        _ordersFuture = _orderService.fetchOrders(); // Refresh the order list after updating
      });
    } catch (e) {
      print("Error updating order status: $e");
    }
  }

  // Function to show order item details in an alert dialog
  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Order ID: ${order['orderId']}"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: order['orderItems'].length,
              itemBuilder: (context, index) {
                Map<String, dynamic> item = order['orderItems'][index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Shoe Name: ${item['shoeName']}"),
                    Text("Size: ${item['shoeSize']}"),
                    Text("Quantity: ${item['quantity']}"),
                    Text("Customized: ${item['customized'] ? "Yes" : "No"}"),
                    Text("Vendor: ${item['vendorUsername']}"),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Function to filter orders by their status
  List<Map<String, dynamic>> _filterOrdersByStatus(List<Map<String, dynamic>> orders, String status) {
    return orders.where((order) => order['orderStatus'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Confirm Orders"),
            Tab(text: "Process Orders"),
            Tab(text: "Shipped Orders"),
            Tab(text: "Delivered Orders"),
          ],
        ),
      ),
      body: _currentUserEmail == null
          ? const Center(child: CircularProgressIndicator()) // Show loading state while retrieving the user's email
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            List<Map<String, dynamic>> orders = snapshot.data!;

            // Filter orders for the current vendor
            List<Map<String, dynamic>> filteredOrders = orders.where((order) =>
                order['orderItems'].any((item) => item['vendorUsername'] == _currentUserEmail)).toList();

            if (filteredOrders.isEmpty) {
              return const Center(child: Text("No orders found for your vendor account."));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_filterOrdersByStatus(filteredOrders, 'Pending'), 'confirm'),
                _buildOrderList(_filterOrdersByStatus(filteredOrders, 'Processing'), 'process'),
                _buildOrderList(_filterOrdersByStatus(filteredOrders, 'Shipped'), 'ship'),
                _buildOrderList(_filterOrdersByStatus(filteredOrders, 'Delivered'), 'deliver'),
              ],
            );
          }

          return const Center(child: Text("No data available."));
        },
      ),
    );
  }

  // Function to build the list of orders, with no orders message
  Widget _buildOrderList(List<Map<String, dynamic>> orders, String action) {
    if (orders.isEmpty) {
      return Center(
        child: Text('No orders to $action.'),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> order = orders[index];
        String nextStatus = _getNextStatus(order['orderStatus']);

        return Card(
          child: ListTile(
            title: Text("Order ID: ${order['orderId']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Customer: ${order['userId']}"),
                Text("Total Price: Rs. ${order['totalPrice']}"),
                Text("Order Date: ${order['orderDate']}"),
                Text("Order Time: ${order['orderTime']}"),
                Text("Items: ${order['orderItems'].length}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showOrderDetails(context, order); // View details button
                      },
                      child: const Text("View Details"),
                    ),
                    const SizedBox(width: 10),
                    nextStatus != null
                        ? ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(order['orderId'], nextStatus); // Update status
                      },
                      child: Text(nextStatus), // Display the next status as the button text
                    )
                        : Container(), // If no next status, do nothing
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // Function to get the next status name based on the current order status
  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Processing';
      case 'Processing':
        return 'Shipped';
      case 'Shipped':
        return 'Delivered';
      default:
        return ''; // or throw an exception, or return a fallback status
    }
  }

}
