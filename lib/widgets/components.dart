import 'package:flutter/material.dart';

class Components {
  static void showErrorSnackBar(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
          // Relative height
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
            ],
          ),
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  static void dashboardWidget(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/Dashboard');
    }
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/BloodPressureEntry');
    }
    if (index == 2) {
      Navigator.pushReplacementNamed(context, '/BloodSugarEntry');
    }
    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/FoodIntakeEntry');
    }
    if (index == 4) {
      Navigator.pushReplacementNamed(context, '/ActivityEntry');
    }
    if (index == 5) {
      Navigator.pushReplacementNamed(context, '/MedicationEntry');
    }
    if (index == 6) {
      Navigator.pushReplacementNamed(context, '/Reports');
    }
  }
}
