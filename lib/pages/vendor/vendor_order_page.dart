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
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  String? _currentUserEmail;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
    _ordersFuture = _orderService.fetchOrders();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserEmail = user.email;
      });
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      setState(() {
        _ordersFuture = _orderService.fetchOrders();
      });
    } catch (e) {
      print("Error updating order status: $e");
    }
  }

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
            Tab(text: "All"),
            Tab(text: "Confirm Orders"),
            Tab(text: "Process Orders"),
            Tab(text: "Shipped Orders"),
            Tab(text: "Delivered Orders"),
          ],
        ),
      ),
      body: _currentUserEmail == null
          ? const Center(child: CircularProgressIndicator())
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
                _buildOrderList(filteredOrders, 'all'), // All orders
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
                Text("Status: ${order['orderStatus']}"),
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
                        _showOrderDetails(context, order);
                      },
                      child: const Text("View Details"),
                    ),
                    const SizedBox(width: 10),
                    nextStatus.isNotEmpty
                        ? ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(order['orderId'], nextStatus);
                      },
                      child: Text(nextStatus),
                    )
                        : Container(),
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

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Processing';
      case 'Processing':
        return 'Shipped';
      case 'Shipped':
        return 'Delivered';
      default:
        return '';
    }
  }
}
