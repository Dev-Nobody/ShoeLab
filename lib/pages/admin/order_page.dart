import 'package:flutter/material.dart';
import 'package:fyp/services/order_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  OrderService _orderService = OrderService(); // Create an instance of OrderService
  late Future<List<Map<String, dynamic>>> _ordersFuture; // Store the future

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.fetchOrders(); // Fetch the orders on init
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Data retrieved successfully
          if (snapshot.hasData) {
            List<Map<String, dynamic>> orders = snapshot.data!;

            if (orders.isEmpty) {
              return const Center(child: Text("No orders found."));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text("Order ID: ${order['orderId']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Customer ${order['userId']}"),
                        Text("Total Price: Rs. ${order['totalPrice']}"),
                        Text("Order Date: ${order['orderDate']}"),
                        Text("Order Time: ${order['orderTime']}"),
                        Text("Items: ${order['orderItems'].length}"),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Show order details in a dialog
                      _showOrderDetails(context, order);
                    },
                  ),
                );
              },
            );
          }

          // Fallback (if no data and no error)
          return const Center(child: Text("No data available."));
        },
      ),
    );
  }
}
