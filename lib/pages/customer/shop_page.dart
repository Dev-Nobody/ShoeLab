import 'package:flutter/material.dart';
import 'package:fyp/components/category_listtile.dart';
import 'package:fyp/components/search_bar.dart';
import 'package:fyp/components/shoe_list_tile.dart';

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 20),

          // Categories Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),

          //Categories List
          Container(
            height: 400, // Set a fixed height for the horizontal ListView
            child: CategoryListTile(),
          ),
          SizedBox(height: 20),

          // All Shoes Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'All Shoes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),

          // All Shoes List
          ShoeListTile(), // Add the list of shoes below the categories

          // SearchBarComponent(collectionName: 'shoes'),
        ],
      ),
    );
  }
}
