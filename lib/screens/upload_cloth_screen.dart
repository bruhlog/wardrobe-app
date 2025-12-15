import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UploadClothScreen extends StatefulWidget {
  const UploadClothScreen({super.key});

  @override
  State<UploadClothScreen> createState() => _UploadClothScreenState();
}

class _UploadClothScreenState extends State<UploadClothScreen> {
  String? base64Image;
  String category = 'Tops';
  bool isSaving = false;

  final ImagePicker picker = ImagePicker();

  /* -------------------- PICK IMAGE -------------------- */
  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 50,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => base64Image = base64Encode(bytes));
    }
  }

  /* -------------------- SAVE CLOTH -------------------- */
  Future<void> saveCloth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || base64Image == null) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('clothes')
        .add({
      'category': category,
      'imageBase64': base64Image,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isSaving = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Clothing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: base64Image == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                    : Image.memory(
                  base64Decode(base64Image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: 'Tops', child: Text('Tops')),
                DropdownMenuItem(value: 'Bottoms', child: Text('Bottoms')),
                DropdownMenuItem(value: 'Shoes', child: Text('Shoes')),
              ],
              onChanged: (value) => setState(() => category = value!),
              decoration: const InputDecoration(
                labelText: 'Clothing Type',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveCloth,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Clothing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
