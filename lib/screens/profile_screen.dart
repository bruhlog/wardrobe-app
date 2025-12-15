import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String gender = 'Male';
  String? base64Image;

  bool isSaving = false;
  bool isLoading = true;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /* -------------------- LOAD PROFILE -------------------- */
  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      heightController.text = data['height'] ?? '';
      weightController.text = data['weight'] ?? '';
      gender = data['gender'] ?? 'Male';
      base64Image = data['profileImageBase64'];
    }

    setState(() => isLoading = false);
  }

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

  /* -------------------- SAVE PROFILE -------------------- */
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'height': heightController.text.trim(),
      'weight': weightController.text.trim(),
      'gender': gender,
      'profileImageBase64': base64Image,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully ✅')),
    );
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: base64Image != null
                    ? MemoryImage(base64Decode(base64Image!))
                    : null,
                child: base64Image == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => gender = value!),
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
