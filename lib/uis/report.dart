import 'package:flutter/material.dart';
import 'package:healthapp/widgets/app_bottom_nav.dart';
import 'package:healthapp/widgets/components.dart';

class buildReport extends StatefulWidget {
  const buildReport({super.key});

  @override
  State<buildReport> createState() => _buildReportState();
}

// ignore: camel_case_types
class _buildReportState extends State<buildReport> {
  int _selectedIndex = 6;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Placeholder(color: Colors.grey),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
