import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:object_3d/object_3d.dart';

class CustomizePage extends StatefulWidget {
  @override
  _CustomizePageState createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  Color selectedColor = Colors.white;

  void changeColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize 3D Model'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                height: 300,
                width: 300,
                color: Colors.grey[200],
                child:

                Object3D(
                  size: const Size(200.0, 200.0),
                  path: "lib/shoesModel/sneakers/sssss.obj",
                  color: selectedColor,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              children: [
                ColorOption(
                  color: Colors.red,
                  onSelected: changeColor,
                ),
                ColorOption(
                  color: Colors.green,
                  onSelected: changeColor,
                ),
                ColorOption(
                  color: Colors.blue,
                  onSelected: changeColor,
                ),
                ColorOption(
                  color: Colors.yellow,
                  onSelected: changeColor,
                ),
                ColorOption(
                  color: Colors.purple,
                  onSelected: changeColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final Function(Color) onSelected;

  ColorOption({required this.color, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 2.0, color: Colors.grey[700]!),
        ),
      ),
    );
  }
}
