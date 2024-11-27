import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class CustomizePage extends StatefulWidget {
  const CustomizePage({super.key});

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  late Object _modelObject;

  @override
  void initState() {
    super.initState();
    // Load the default model (e.g., white model)
    _modelObject = Object(fileName: "lib/shoesModel/nehigh/red/single_shoes.obj");
  }

  void updateModel(String modelPath) {
    setState(() {
      // Update the 3D model with the new file path
      _modelObject = Object(fileName: modelPath);
    });
  }

  Widget build3DModel() {
    return SizedBox(
      height: 400,
      child: Cube(
        onSceneCreated: (Scene scene) {
          scene.world.add(_modelObject);
          scene.camera.zoom = 10;
          scene.light.position.setFrom(Vector3(0, 10, 10));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customize Model")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          build3DModel(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => updateModel("lib/shoesModel/nehigh/red/single_shoes.obj"),
                child: const Text("Red"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () => updateModel("lib/shoesModel/nehigh/black/single_shoes.obj"),
                child: const Text("Black"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => updateModel("lib/shoesModel/nehigh/white/single_shoes.obj"),
                child: const Text("White"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
