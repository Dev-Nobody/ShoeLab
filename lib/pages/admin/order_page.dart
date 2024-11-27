import 'package:flutter/material.dart';
import 'package:fyp/services/order_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.fetchOrders();
  }

  // Function to delete an order
  void _deleteOrder(orderId) async {
    try {
      await _orderService.deleteOrder(orderId); // Assuming deleteOrder is implemented in OrderService
      setState(() {
        // Refresh the orders after deletion
        _ordersFuture = _orderService.fetchOrders();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF161822),
        title: const Text("Orders", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color(0xFF161822),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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

            if (orders.isEmpty) {
              return const Center(child: Text("No orders found."));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> order = orders[index];
                List<Map<String, dynamic>> orderItems =
                (order['orderItems'] as List<dynamic>).cast<Map<String, dynamic>>();

                return Card(
                  color: Color(0xFF2A2D40),
                  child: ExpansionTile(
                    title: Text(
                      "Order ID: ${order['orderId']}",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            // Show confirmation dialog before deletion
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Delete Order"),
                                  content: Text("Are you sure you want to delete this order?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteOrder(order['orderId']);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Customer ${order['userId']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Items: ${orderItems.length}",
                            style: TextStyle(color: Colors.white),
                          ),
                          // Displaying images and names of order items
                          Column(
                            children: orderItems.map<Widget>((item) {
                              return FutureBuilder<Map<String, dynamic>>(
                                future: _orderService.fetchShoeById(item['shoeId']),
                                builder: (context, shoeSnapshot) {
                                  if (shoeSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (shoeSnapshot.hasError) {
                                    return Text(
                                      'Error fetching shoe details',
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }

                                  Map<String, dynamic> shoeDetails = shoeSnapshot.data!;
                                  return Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF161822),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: ListTile(
                                          leading: Image.network(
                                            shoeDetails['imagePath'] ?? '',
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                          ),
                                          title: Text(
                                            shoeDetails['name'] ?? 'Unknown Item',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          Text(
                            "Total Price: Rs. ${order['totalPrice']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "${order['orderDate']} ${order['orderTime']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Status: ${order['orderStatus']}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(child: Text("No data available."));
        },
      ),
    );
  }
}
