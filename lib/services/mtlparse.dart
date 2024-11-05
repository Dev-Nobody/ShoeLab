import 'dart:io';

Future<String> loadMtlFile(String path) async {
  try {
    return await File(path).readAsString();
  } catch (e) {
    print("Error loading MTL file: $e");
    return '';
  }
}

String updateMtlValues(String mtlContent, String materialName, List<double> newKdValues) {
  final lines = mtlContent.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('newmtl') && lines[i].contains(materialName)) {
      // Found the material block, now look for the Kd line to update
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

Future<void> saveMtlFile(String path, String content) async {
  try {
    await File(path).writeAsString(content);
  } catch (e) {
    print("Error saving MTL file: $e");
  }
}
