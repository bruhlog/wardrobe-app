import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class UploadClothScreen extends StatefulWidget {
  const UploadClothScreen({super.key});

  @override
  State<UploadClothScreen> createState() => _UploadClothScreenState();
}

class _UploadClothScreenState extends State<UploadClothScreen> {
  final nameController = TextEditingController();
  String category = 'Tops';
  String? imageBase64;
  bool isSaving = false;

  final picker = ImagePicker();

  /* -------------------- PICK IMAGE -------------------- */
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        imageQuality: 50,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => imageBase64 = base64Encode(bytes));
      }
    } catch (_) {
      _showError("Failed to pick image");
    }
  }

  /* -------------------- INTERNET CHECK -------------------- */
  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /* -------------------- BACKGROUND REMOVAL -------------------- */
  Future<String?> removeBackground(String base64) async {
    try {
      final response = await http
          .post(
        Uri.parse("https://wardrobe-backend-7q4o.onrender.com/remove-bg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"imageBase64": base64}),
      )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["cleanedImageBase64"];
      }
    } catch (_) {
      // Silent fallback
    }
    return null;
  }

  /* -------------------- SAVE CLOTH -------------------- */
  Future<void> saveCloth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || imageBase64 == null) {
      _showError("Missing data");
      return;
    }

    if (!await hasInternet()) {
      _showError("No internet connection");
      return;
    }

    setState(() => isSaving = true);

    String? cleanedImage;

    try {
      cleanedImage = await removeBackground(imageBase64!);
    } catch (_) {
      cleanedImage = null;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clothes')
          .add({
        'name': nameController.text.trim(),
        'category': category,
        'imageBase64': imageBase64,
        'cleanedImageBase64': cleanedImage,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      _showError("Upload failed");
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Clothing")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Clothing Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageBase64 == null
                  ? const Center(child: Icon(Icons.add_a_photo))
                  : Image.memory(
                base64Decode(imageBase64!),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField(
            value: category,
            items: const [
              DropdownMenuItem(value: 'Tops', child: Text('Tops')),
              DropdownMenuItem(value: 'Bottoms', child: Text('Bottoms')),
              DropdownMenuItem(value: 'Shoes', child: Text('Shoes')),
            ],
            onChanged: (v) => setState(() => category = v!),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: isSaving ? null : saveCloth,
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save"),
          ),
        ]),
      ),
    );
  }
}
