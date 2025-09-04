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
}
