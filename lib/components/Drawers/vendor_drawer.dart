import 'package:flutter/material.dart';
import 'package:fyp/components/my_list_tile.dart';
import 'package:fyp/pages/user_profile.dart';


class VendorDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onProductTap;
  final void Function()? onOrderTap;
  final void Function()? onChatTap;
  // final void Function()? onSignOut;
  // final void Function()? onSettings;
  // final void Function()? onMessageTap;
  // final void Function()? onTrackTap;
  // final void Function()? onGalleryTap;

  const VendorDrawer(
      {super.key,
        required this.onProfileTap,
        required this.onProductTap,
        required this.onOrderTap,
        required this.onChatTap,
        // required this.onSignOut,
        // required this.onSettings,
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
              
                  //products
                  MyListTile(
                    icon: Icons.production_quantity_limits,
                    text: 'P R O D U C T S',
                    onTap:  onProductTap,
                  ),
              
                  //order fulfillment
                  MyListTile(
                    icon: Icons.person,
                    text: 'O R D E R',
                    onTap:  onOrderTap,
                  ),

              
                  //communication tools
                  MyListTile(
                    icon: Icons.chat,
                    text: 'C H A T',
                    onTap:  onChatTap,
                  ),
              
                  //profile
                  // MyListTile(
                  //   icon: Icons.person,
                  //   text: 'F E E D B A C K',
                  //   onTap:  onProfileTap,
                  // ),
                  //
                  // //profile
                  // MyListTile(
                  //   icon: Icons.person,
                  //   text: 'P A Y M E N T ',
                  //   onTap:  onProfileTap,
                  // ),
                  //
                  // //profile
                  // MyListTile(
                  //   icon: Icons.person,
                  //   text: 'C O M P L I A N C E ',
                  //   onTap:  onProfileTap,
                  // ),
                  //

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

