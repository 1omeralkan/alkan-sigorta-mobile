import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alkan_sigorta_mobile/core/constants/app_theme.dart';
import 'package:alkan_sigorta_mobile/core/routes/app_router.dart';

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
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
