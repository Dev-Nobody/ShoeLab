import 'package:flutter/material.dart';
import 'package:fyp/components/receipt.dart';
import 'package:fyp/pages/customer/home_page.dart';


class DeliveryProgressPage extends StatefulWidget {
  final List<Map<String, dynamic>> checkedItems;

  const DeliveryProgressPage({
    super.key,
    required this.checkedItems,
  });

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delvery in Progress..',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey.shade900,
      bottomNavigationBar: GestureDetector(
        onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => HomePage(),)),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.lightGreenAccent.shade100,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          ),
          child: const Center(child: Text("Continue Shopping",style: TextStyle(fontSize: 20),),),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyReceipt(
              checkedItems: widget.checkedItems,
            ),
          ],
        ),
      ),
    );
  }
}
