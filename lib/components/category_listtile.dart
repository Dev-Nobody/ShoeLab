import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/pages/customer/category_shoes_page.dart';
import 'package:list_wheel_scroll_view_nls/list_wheel_scroll_view_nls.dart';

class CategoryListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No categories found.'));
        }

        final categories = snapshot.data!.docs;

        return Container(
          height: 400, // Set a fixed height for the horizontal scroll
          child: ListWheelScrollViewX(
            scrollDirection: Axis.horizontal,
            itemExtent: 270, // Adjust width spacing between items
            children: categories.map((category) {
              return GestureDetector(
                onTap: () {
                  print('Category ID: ${category.id}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoesByCategoryPage(
                        categoryId: category.id,
                        categoryName: category['name'],
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                        height: 400,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(52),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0, top: 30),
                                  child: Text(
                                    category['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    category['name'].toString().toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 80,
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 0,
                      child: Image.network(
                        category['image'],
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
