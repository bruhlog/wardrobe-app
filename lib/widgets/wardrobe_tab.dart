import 'package:flutter/material.dart';

class WardrobeTab extends StatelessWidget {
  final String category;

  const WardrobeTab({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Dummy clothes for now
    final items = List.generate(
      6,
          (index) => '$category Item ${index + 1}',
    );

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
          child: Center(
            child: Text(
              items[index],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
