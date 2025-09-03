import 'package:flutter/material.dart';
import 'package:healthapp/auth/login.dart';
import 'package:healthapp/auth/register.dart';
import 'package:healthapp/splashScreen.dart';
import 'package:healthapp/uis/dashboard.dart';
import 'package:healthapp/uis/dataEntry.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/Login': (context) => const Login(),
        '/Regsiter': (context) => const Register(),
        '/Dashboard': (context) => const Dashboard(),
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
