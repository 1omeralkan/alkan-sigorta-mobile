import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const AlkanSigortaApp());
}

class AlkanSigortaApp extends StatelessWidget {
  const AlkanSigortaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alkan Sigorta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Alkan Sigorta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
