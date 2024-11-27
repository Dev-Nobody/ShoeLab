import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/pages/customer/review_page.dart';
import 'package:fyp/pages/customer/shoes_page.dart';
import 'package:fyp/services/order_service.dart';
import 'package:fyp/services/shoes_services.dart';

class CustomerOrderPage extends StatefulWidget {
  final int initialTabIndex;

  const CustomerOrderPage({super.key, this.initialTabIndex = 0});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage>
    with SingleTickerProviderStateMixin {
  OrderService _orderService = OrderService();
  ShoeService _shoeService = ShoeService();  // New service to fetch shoe details
  Future<List<Map<String, dynamic>>>? _ordersFuture;
  TabController? _tabController;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  void _getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserEmail = user.email;
        _ordersFuture = _orderService.fetchOrders();
      });
    }
  }

  List<Map<String, dynamic>> _filterOrdersByUser(List<Map<String, dynamic>> orders) {
    if (_currentUserEmail == null) return [];
    return orders.where((order) => order['userId'] == _currentUserEmail).toList();
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
        title: const Text("Customer Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Pending"),
            Tab(text: "To Ship"),
            Tab(text: "To Receive"),
            Tab(text: "To Review"),
          ],
        ),
      ),
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
            List<Map<String, dynamic>> orders = _filterOrdersByUser(snapshot.data!);

            if (orders.isEmpty) {
              return const Center(child: Text("No orders found."));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(orders),
                _buildOrderList(_filterOrdersByStatus(orders, 'Pending')),
                _buildOrderList(_filterOrdersByStatus(orders, 'Processing')),
                _buildOrderList(_filterOrdersByStatus(orders, 'Shipped')),
                _buildOrderList(_filterOrdersByStatus(orders, 'Delivered')),
              ],
            );
          }

          return const Center(child: Text("No data available."));
        },
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('No orders available.'),
      );
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
                SizedBox(height: 10),
                Column(
                  children: order['orderItems'].map<Widget>((item) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _orderService.fetchShoeById(item['shoeId']), // Fetch shoe by ID
                      builder: (context, shoeSnapshot) {
                        if (shoeSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (shoeSnapshot.hasError) {
                          return Text("Error fetching shoe details");
                        }

                        if (shoeSnapshot.hasData) {
                          var shoe = shoeSnapshot.data!;
                          return GestureDetector(
                            onTap: () {
                              // Navigate to ShoePage with shoeId
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoesPage(shoeId: item['shoeId']),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Image.network(shoe['imagePath'], width: 50, height: 50),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(shoe['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(shoe['description']),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Rs. ${shoe['price']}"),
                                          Text("Qty: ${item['quantity']}"),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return const Center(child: Text("No shoe details available."));
                      },
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Total: Rs. ${order['totalPrice']}"),
                  ],
                ),
                Text("Status: ${order['orderStatus']}"),
                if (order['orderStatus'] == 'Delivered')
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewPage(orderId: order['orderId']),
                          ),
                        );
                      },
                      child: const Text("Review"),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}
