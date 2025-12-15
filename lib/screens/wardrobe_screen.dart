import 'package:flutter/material.dart';
import 'upload_cloth_screen.dart';
import '../widgets/wardrobe_tab.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Wardrobe'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tops'),
              Tab(text: 'Bottoms'),
              Tab(text: 'Shoes'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadClothScreen()),
            );
          },
        ),
        body: const TabBarView(
          children: [
            WardrobeTab(category: 'Tops'),
            WardrobeTab(category: 'Bottoms'),
            WardrobeTab(category: 'Shoes'),
          ],
        ),
      ),
    );
  }
}
