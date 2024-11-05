import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:path_provider/path_provider.dart';

class Try extends StatefulWidget {
  const Try({super.key});

  @override
  State<Try> createState() => _TryState();
}

class _TryState extends State<Try> {
  Color selectedColor = Colors.white;
  late Object _modelObject;

  // Path to your MTL file
  final String mtlPath = 'assets/shoesModel/sneakers/sssss.mtl';

  Future<String> loadMtlFile(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print("Error loading MTL file: $e");
      return '';
    }
  }

  Future<void> saveMtlFile(String content) async {
    final directory = await getTemporaryDirectory();
    final tempPath = '${directory.path}/sssss.mtl';
    try {
      await File(tempPath).writeAsString(content);
      print("MTL file saved at $tempPath");
    } catch (e) {
      print("Error saving MTL file: $e");
    }
  }

  String updateMtlValues(String mtlContent, String materialName, List<double> newKdValues) {
    final lines = mtlContent.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('newmtl') && lines[i].contains(materialName)) {
        for (int j = i + 1; j < lines.length; j++) {
          if (lines[j].startsWith('Kd')) {
            lines[j] = 'Kd ${newKdValues.join(' ')}';
            break;
          }
          if (lines[j].startsWith('newmtl')) break;
        }
        break;
      }
    }
    return lines.join('\n');
  }

  Future<void> updateMaterialColor(String materialName, Color color) async {
    final newKdValues = [
      color.red / 255.0,
      color.green / 255.0,
      color.blue / 255.0,
    ];

    String mtlContent = await loadMtlFile(mtlPath);
    String updatedMtlContent = updateMtlValues(mtlContent, materialName, newKdValues);
    print("Updated MTL file content:\n$updatedMtlContent");
    await saveMtlFile(updatedMtlContent);

    setState(() {
      // Reload the 3D model to apply the updated color
      _modelObject = Object(fileName: "assets/shoesModel/sneakers/sssss.obj");
    });
  }

  @override
  void initState() {
    super.initState();
    _modelObject = Object(fileName: "assets/shoesModel/sneakers/sssss.obj");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("3D Model Viewer")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            child: Cube(
              onSceneCreated: (Scene scene) {
                scene.world.add(_modelObject);
                scene.camera.zoom = 10;
                scene.light.position.setFrom(Vector3(0, 10, 10));
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Pick a Color"),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          selectedColor = color;
                        },
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Done'),
                        onPressed: () {
                          updateMaterialColor('initialShadingGroup', selectedColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text("Pick Material Color"),
          ),
        ],
      ),
    );
  }
}



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:flutter_cube/flutter_cube.dart';
// import 'package:path_provider/path_provider.dart';
//
// class Try extends StatefulWidget {
//   const Try({super.key});
//
//   @override
//   State<Try> createState() => _TryState();
// }
//
// class _TryState extends State<Try> {
//   Color selectedColor = Colors.white;
//   late Object _modelObject;
//
//   // Path to your MTL file
//   final String mtlPath = 'assets/shoesModel/sneakers/sssss.mtl';
//
//   // Load MTL file from assets
//   Future<String> loadMtlFile(String path) async {
//     try {
//       return await rootBundle.loadString(path);
//     } catch (e) {
//       print("Error loading MTL file: $e");
//       return '';
//     }
//   }
//
//   // Copy MTL file to a temporary location on the device
//   Future<String> copyMtlFileToTemp() async {
//     // Load MTL file from assets
//     final data = await rootBundle.load(mtlPath);
//     // Get the temporary directory
//     final directory = await getTemporaryDirectory();
//     // Define the new path for the MTL file
//     final tempPath = '${directory.path}/sssss.mtl';
//     // Write the MTL file to the temporary directory
//     final file = File(tempPath);
//     await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//     return tempPath;
//   }
//
//   // Save modified MTL content to a temporary location on the device
//   Future<void> saveMtlFile(String content, String path) async {
//     try {
//       await File(path).writeAsString(content);
//       print("MTL file saved at $path");
//     } catch (e) {
//       print("Error saving MTL file: $e");
//     }
//   }
//
//   String updateMtlValues(String mtlContent, String materialName, List<double> newKdValues) {
//     final lines = mtlContent.split('\n');
//     for (int i = 0; i < lines.length; i++) {
//       if (lines[i].startsWith('newmtl') && lines[i].contains(materialName)) {
//         for (int j = i + 1; j < lines.length; j++) {
//           if (lines[j].startsWith('Kd')) {
//             lines[j] = 'Kd ${newKdValues.join(' ')}';
//             break;
//           }
//           if (lines[j].startsWith('newmtl')) break;
//         }
//         break;
//       }
//     }
//     return lines.join('\n');
//   }
//
//   Future<void> updateMaterialColor(String materialName, Color color) async {
//     final newKdValues = [
//       color.red / 255.0,
//       color.green / 255.0,
//       color.blue / 255.0,
//     ];
//
//     // Copy the MTL file to a temporary path
//     String tempMtlPath = await copyMtlFileToTemp();
//     String mtlContent = await File(tempMtlPath).readAsString();
//     String updatedMtlContent = updateMtlValues(mtlContent, materialName, newKdValues);
//
//     // Save the updated MTL content back to the temporary file
//     await saveMtlFile(updatedMtlContent, tempMtlPath);
//
//     // Reload the 3D model with the updated MTL file
//     setState(() {
//       // After saving, load the updated object, as the 'flutter_cube' package uses the mtl file in the obj.
//       _modelObject = Object(
//         fileName: "assets/shoesModel/sneakers/sssss.obj", // Keep the OBJ path
//       );
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // Initially load the model object
//     _modelObject = Object(fileName: "assets/shoesModel/sneakers/sssss.obj");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("3D Model Viewer")),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             height: 400,
//             child: Cube(
//               onSceneCreated: (Scene scene) {
//                 scene.world.add(_modelObject);
//                 scene.camera.zoom = 10;
//                 scene.light.position.setFrom(Vector3(0, 10, 10));
//               },
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Text("Pick a Color"),
//                     content: SingleChildScrollView(
//                       child: ColorPicker(
//                         pickerColor: selectedColor,
//                         onColorChanged: (color) {
//                           selectedColor = color;
//                         },
//                       ),
//                     ),
//                     actions: <Widget>[
//                       ElevatedButton(
//                         child: Text('Done'),
//                         onPressed: () {
//                           // Use the exact material name you want to modify
//                           updateMaterialColor('initialShadingGroup', selectedColor);
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Text("Pick Material Color"),
//           ),
//         ],
//       ),
//     );
//   }
// }
//