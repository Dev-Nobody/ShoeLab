import 'package:flutter/material.dart';

class Bla extends StatefulWidget {
  const Bla({super.key});

  @override
  State<Bla> createState() => _BlaState();
}

class _BlaState extends State<Bla> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('Hello world')
          ],
        ),
      ),
    );
  }
}
