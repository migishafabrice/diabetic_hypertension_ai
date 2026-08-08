import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diacare/auth/login.dart';
import 'package:diacare/auth/register.dart';
import 'package:diacare/splashScreen.dart';
import 'package:diacare/uis/dashboard.dart';
import 'package:diacare/uis/dataEntry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:diacare/uis/report.dart';
import 'package:diacare/uis/health_analysis.dart';
import 'package:diacare/uis/ai_recommendations.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      routes: {
        '/Login': (context) => const Login(),
        '/Register': (context) => const Register(),
        '/Dashboard': (context) => const Dashboard(userData: {}),
        '/BloodPressureEntry': (context) => const BloodPressureEntry(),
        '/BloodSugarEntry': (context) => const BloodSugarEntry(),
        '/ActivityEntry': (context) => const PhysicalExerciseEntry(),
        '/FoodIntakeEntry': (context) => const FoodIntakeEntry(),
        '/BodyMeasurementEntry': (context) => const BodyMeasurementEntry(),
        '/Splashscreen': (context) => const Splashscreen(),
        '/MedicationEntry': (context) => const MedicationEntry(),
        '/SymptomsEntry': (context) => const SymptomsEntry(),
        '/Report': (context) => const BuildReport(),
        '/HealthAnalysis': (context) => const HealthAnalysis(),
        '/AIRecommendations': (context) => const AIRecommendationsScreen(),
      },
      home: const Splashscreen(),
    );
  }
}
