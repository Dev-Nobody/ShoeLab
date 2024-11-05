import 'package:flutter/material.dart';
import 'package:fyp/components/search_bar.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor:  Colors.grey.shade900,
      ),
      body: SearchBarComponent(collectionName: 'shoes'),
    );
  }
}
