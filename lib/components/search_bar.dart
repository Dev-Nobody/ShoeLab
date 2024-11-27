import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/pages/customer/shoes_page.dart';

class SearchBarComponent extends StatefulWidget {
  final String collectionName;

  const SearchBarComponent({Key? key, required this.collectionName}) : super(key: key);

  @override
  _SearchBarComponentState createState() => _SearchBarComponentState();
}

class _SearchBarComponentState extends State<SearchBarComponent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          style: TextStyle(color: Colors.white),
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: InputDecoration(
            labelText: 'Search',
            labelStyle: TextStyle(color: Colors.lightGreenAccent.shade100),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightGreenAccent.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightGreenAccent.shade100, width: 2.0),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _searchQuery.isEmpty
                ? Stream<QuerySnapshot>.empty()
                : FirebaseFirestore.instance
                .collection(widget.collectionName)
                .where('name', isGreaterThanOrEqualTo: _searchQuery.toLowerCase())
                .where('name', isLessThanOrEqualTo: _searchQuery.toLowerCase() + '\uf8ff')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No results found.'));
              }

              final items = snapshot.data!.docs;

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index].data() as Map<String, dynamic>;
                  final shoeId = items[index].id;

                  return ListTile(
                    title: Text(
                      item['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      item['brand'],
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      'Rs.${item['price']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: item['imagePath'] != null
                        ? Image.network(item['imagePath'])
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoesPage(shoeId: shoeId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

