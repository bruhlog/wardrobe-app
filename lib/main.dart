import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* -------------------- ROOT APP -------------------- */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wardrobe App',
      home: const HomeScreen(),
    );
  }
}

/* ==================== DAY 5 ==================== */
/* -------------------- HOME SCREEN -------------------- */
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Wardrobe'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Profile'),
          onPressed: () {
            /* NAVIGATOR.PUSH */
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ==================== DAY 6 ==================== */
/* -------------------- PROFILE SCREEN -------------------- */
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /* CONTROLLERS */
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            /* NAVIGATOR.POP */
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /* HEIGHT INPUT */
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /* WEIGHT INPUT */
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /* SAVE BUTTON */
            ElevatedButton(
              onPressed: () {
                String height = heightController.text;
                String weight = weightController.text;

                /* TEMP: PRINT VALUES */
                debugPrint('Height: $height cm');
                debugPrint('Weight: $weight kg');
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
