import 'package:flutter/material.dart';
import 'package:fyp/components/my_list_tile.dart';
import 'package:fyp/pages/user_profile.dart';


class AdminDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onUserTap;
  final void Function()? onVendorTap;
  final void Function()? onCategoryTap;
  final void Function()? onProductTap;
  final void Function()? onFeedbackTap;
  final void Function()? onOrderTap;
  // final void Function()? onSignOut;
  final void Function()? onSettings;
  // final void Function()? onMessageTap;
  // final void Function()? onTrackTap;
  // final void Function()? onGalleryTap;

  const AdminDrawer(
      {super.key,
        required this.onProfileTap,
        required this.onUserTap,
        required this.onVendorTap,
        required this.onCategoryTap,
        required this.onProductTap,
        required this.onFeedbackTap,
        required this.onOrderTap,
        // required this.onSignOut,
        required this.onSettings,
        // required this.onMessageTap,
        //   required this.onTrackTap,
        //   required this.onGalleryTap,
      });

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  //logo
                  DrawerHeader(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    child: Image.asset(
                      'lib/images/shoelab.png',
                      color: Colors.white,
                      width: 300,
                    ),
                  ),
          
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Divider(
                      color: Colors.grey[800],
                    ),
                  ),
          
                  //home
                  MyListTile(
                    icon: Icons.home,
                    text: 'H O M E',
                    onTap: () => Navigator.pop(context),
                  ),
          
                  //profile
                  MyListTile(
                    icon: Icons.person,
                    text: 'P R O F I L E',
                    onTap:  onProfileTap,
                  ),
          
                  //users
                  MyListTile(
                    icon: Icons.perm_contact_cal_sharp,
                    text: 'U S E R S',
                    onTap:  onUserTap,
                  ),
          
                  // vendors
                  MyListTile(
                    icon: Icons.personal_injury_outlined,
                    text: 'V E N D O R S',
                    onTap:  onVendorTap,
                  ),
          
                  //orders
                  MyListTile(
                    icon: Icons.person,
                    text: 'O R D E R S ',
                    onTap:  onOrderTap,
                  ),
          
                  //category
                  MyListTile(
                    icon: Icons.category,
                    text: 'C A T E G O R Y ',
                    onTap:  onCategoryTap,
                  ),
          
                  //products
                  MyListTile(
                    icon: Icons.person,
                    text: 'P R O D U C T S ',
                    onTap:  onProductTap,
                  ),
          
                  //feedback
                  MyListTile(
                    icon: Icons.person,
                    text: 'F E E D B A C K ',
                    onTap:  onFeedbackTap,
                  ),

                  //feedback
                  MyListTile(
                    icon: Icons.person,
                    text: 'S E T T I N G',
                    onTap:  onSettings,
                  ),
          
                  //contnet
                  MyListTile(
                    icon: Icons.person,
                    text: 'C O N T E N T ( X )',
                    onTap:  onProfileTap,
                  ),
          
                  //logout
                  MyListTile(
                    icon: Icons.logout,
                    text: 'L O G O U T',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}

