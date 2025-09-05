import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/auth/login.dart';
import 'package:healthapp/auth/register.dart';
import 'package:healthapp/provider/authProvider.dart';
import 'package:healthapp/splashScreen.dart';
import 'package:healthapp/uis/dashboard.dart';
import 'package:healthapp/uis/dataEntry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final authState = ref.watch(authProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/Login': (context) => Login(),
        '/Register': (context) => Register(),
        '/Dashboard': (context) => const Dashboard(userData: {}),
        '/BloodPressureEntry': (context) => BloodPressureEntry(),
        '/BloodSugarEntry': (context) => BloodSugarEntry(),
        '/ActivityEntry': (context) => PhysicalExerciseEntry(),
        '/FoodIntakeEntry': (context) => FoodIntakeEntry(),
        //'/Reports': (context) => const Reports(),
        '/Splashscreen': (context) => const Splashscreen(),
        '/MedicationEntry': (context) => MedicationEntry(),
      },
      home: const Splashscreen(),
    );
  }
}
