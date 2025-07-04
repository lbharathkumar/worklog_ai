import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/project.dart'; // Ensure you have this
import 'screens/home_screen.dart'; // Ensure this screen shows bottom nav

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(ProjectAdapter());
  await Hive.openBox<Project>('projectsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkLog AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomeScreen(), // ✅ this loads bottom bar
      debugShowCheckedModeBanner: false,
    );
  }
}
