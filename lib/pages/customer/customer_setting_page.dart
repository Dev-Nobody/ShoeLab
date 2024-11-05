import 'package:flutter/material.dart';
import 'package:fyp/components/my_list_tile.dart';
import 'package:fyp/pages/customer/account_information.dart';

class CustomerSettingPage extends StatefulWidget {
  const CustomerSettingPage({super.key});

  @override
  State<CustomerSettingPage> createState() => _CustomerSettingPageState();
}

class _CustomerSettingPageState extends State<CustomerSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountInformation(),
                  ),
                );
              },
              child: ListTile(

                tileColor: Colors.grey.shade300,
                title: const Text('Account Information'),
              ),
            ),
            MyListTile(icon: Icons.person, text: 'Account', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountInformation(),
                ),
              );
            },)
            ],
        ),
      ),
    );
  }
}
