// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  Map<String, String> nutritionInfo = {};

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _processImage();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _processImage() async {
    if (_imageFile != null) {
      final inputImage = InputImage.fromFile(_imageFile!);
      final textRecognizer = TextRecognizer();
      final RecognizedText result = await textRecognizer.processImage(inputImage);

      List<TextBlock> blocks = result.blocks;

      // Sort blocks to read left-to-right, top-to-bottom
      blocks.sort((a, b) {
        final aRect = a.boundingBox;
        final bRect = b.boundingBox;

        if (aRect.top.compareTo(bRect.top) != 0) {
          return aRect.top.compareTo(bRect.top);
        } else {
          return aRect.left.compareTo(bRect.left);
        }
      });

      nutritionInfo = {};
      String? currentSection;
      String? currentValue;

      for (TextBlock block in blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();

          if (_isLikelySection(text)) {
            if (currentSection != null && currentValue != null) {
              nutritionInfo[currentSection] = currentValue;
            }

            currentSection = text;
            currentValue = null;
          } else if (_isLikelyValue(text)) {
            currentValue = text;

            // Directly assign if a valid section exists
            if (currentSection != null) {
              nutritionInfo[currentSection] = currentValue;
              currentSection = null;
              currentValue = null;
            }
          } else {
            // Handle unexpected format: treat as a new section or value
            if (currentSection != null) {
              nutritionInfo[currentSection] = text;
              currentSection = null;
              currentValue = null;
            } else {
              currentSection = text;
            }
          }
        }
      }

      // Add any remaining section-value pair
      if (currentSection != null && currentValue != null) {
        nutritionInfo[currentSection] = currentValue;
      }

      setState(() {});

      textRecognizer.close();
    }
  }

  // Helper function to determine if a string is likely a section (e.g., "Calories")
  bool _isLikelySection(String text) {
    // This checks if the text is a known section keyword or similar pattern
    return text.contains(RegExp(r'^\D+$')); // Assuming sections are non-numeric
  }

  // Helper function to determine if a string is likely a value (e.g., "200 kcal")
  bool _isLikelyValue(String text) {
    return text.contains(RegExp(r'^\d+(\.\d+)?\s?[a-zA-Z]*$')); // Numeric values with possible units
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nutrition Label Reader"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile == null
                  ? Text('Select an image to analyze')
                  : Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick Image"),
              ),
              SizedBox(height: 20),
              nutritionInfo.isEmpty
                  ? Text('No text recognized yet.')
                  : NutritionInfoWidget(nutritionInfo: nutritionInfo),
            ],
          ),
        ),
      ),
    );
  }
}

class NutritionInfoWidget extends StatelessWidget {
  final Map<String, String> nutritionInfo;

  const NutritionInfoWidget({Key? key, required this.nutritionInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: nutritionInfo.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: HomePage()));
}
