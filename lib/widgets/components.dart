import 'package:flutter/material.dart';

void showErrorSnackBar(
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

void dashboardWidget(BuildContext context, int index) {
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
  // if (index == 5) {
  //   Navigator.pushReplacementNamed(context, '/MedicationEntry');
  // }
  if (index == 6) {
    Navigator.pushReplacementNamed(context, '/Reports');
  }
  if (index == 100) {
    Navigator.pushReplacementNamed(context, '/MedicationEntry');
  }
}

int? safeParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  if (value is bool) return value ? 1 : 0;
  return null;
}

String safeParseString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

DateTime safeParseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }
  return DateTime.now();
}

TimeOfDay postgresStringToTimeOfDay(String timeString) {
  try {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  } catch (e) {
    return TimeOfDay.now();
  }
}

double safeParseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

String timeOfDayToPostgresString(TimeOfDay timeOfDay) {
  return "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}";
}
