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
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Center(child: Text('Settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            MyListTile(icon: Icons.person, text: 'Account Information', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountInformation(),
                ),
              );
            },),
            MyListTile(icon: Icons.book, text: 'Address Book', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountInformation(),
                ),
              );
            },),
            MyListTile(icon: Icons.local_police_outlined, text: 'Policies', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountInformation(),
                ),
              );
            },),
            MyListTile(icon: Icons.delete_forever_sharp, text: 'Request Account Deletion', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountInformation(),
                ),
              );
            },),


          Spacer(),
          // SizedBox(height: 100,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade800,
                child: TextButton(onPressed: (){}, child: Text("Logout",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 15),)),
              ),
            ),
            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}
