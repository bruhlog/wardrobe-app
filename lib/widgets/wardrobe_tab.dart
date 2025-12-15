import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeTab extends StatelessWidget {
  final String category;
  const WardrobeTab({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clothes')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        /* ---------- LOADING ---------- */
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        /* ---------- ERROR ---------- */
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load items'));
        }

        final docs = snapshot.data?.docs ?? [];

        /* ---------- EMPTY ---------- */
        if (docs.isEmpty) {
          return const Center(child: Text('No items added yet'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final String? imageBase64 =
                data['cleanedImageBase64'] ?? data['imageBase64'];

            Uint8List? imageBytes;

            if (imageBase64 != null) {
              try {
                imageBytes = base64Decode(imageBase64);
              } catch (_) {
                imageBytes = null;
              }
            }

            final String name = data['name'] ?? '';

            return GestureDetector(
              onLongPress: () {
                _showManageSheet(
                  context: context,
                  docRef: doc.reference,
                  currentName: name,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    /* IMAGE */
                    Positioned.fill(
                      child: imageBytes == null
                          ? Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                        ),
                      )
                          : Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /* NAME OVERLAY */
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /* -------------------- MANAGE SHEET -------------------- */
  void _showManageSheet({
    required BuildContext context,
    required DocumentReference docRef,
    required String currentName,
  }) {
    final TextEditingController controller =
    TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Manage Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /* RENAME */
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Rename item',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await docRef.update({
                      'name': controller.text.trim(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Rename'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    await docRef.delete();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
