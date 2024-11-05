import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: InputDecoration(
            labelText: 'Search',
            border: OutlineInputBorder(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _searchQuery.isEmpty
                ? Stream<QuerySnapshot>.empty() // Show empty stream when search is empty
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
                  return ListTile(
                    title: Text(item['name'],style:TextStyle(color: Colors.white),), // Change according to your field
                    subtitle: Text(item['brand'],style:TextStyle(color: Colors.grey),), // Change according to your field
                    trailing: Text('Rs.${item['price']}',style:TextStyle(color: Colors.white),), // Change according to your field
                    leading: item['imagePath'] != null
                        ? Image.network(item['imagePath'])
                        : null,
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
