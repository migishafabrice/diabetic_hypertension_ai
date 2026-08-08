import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  final GlobalKey _medicationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          BottomNavItem(
            icon: CupertinoIcons.home,
            label: 'Home',
            isSelected: widget.selectedIndex == 0,
            onTap: () => widget.onTap(0),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: CupertinoIcons.heart,
            label: 'Hearth',
            isSelected: widget.selectedIndex == 1,
            onTap: () => widget.onTap(1),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: CupertinoIcons.drop,
            label: 'Diabetes',
            isSelected: widget.selectedIndex == 2,
            onTap: () => widget.onTap(2),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: Icons.fastfood,
            label: 'Food',
            isSelected: widget.selectedIndex == 3,
            onTap: () => widget.onTap(3),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: Icons.directions_run,
            label: 'Activity',
            isSelected: widget.selectedIndex == 4,
            onTap: () => widget.onTap(4),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            key: _medicationKey,
            icon: Icons.medical_services,
            label: 'Medication',
            isSelected: widget.selectedIndex == 5,
            onTap: () => widget.onTap(5),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: Icons.line_weight,
            label: 'BMI',
            isSelected: widget.selectedIndex == 6,
            onTap: () => widget.onTap(6),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: Icons.sentiment_dissatisfied,
            label: 'Symptoms',
            isSelected: widget.selectedIndex == 7,
            onTap: () => widget.onTap(7),
          ),
          const SizedBox(width: 8),
          BottomNavItem(
            icon: Icons.report,
            label: 'Reports',
            isSelected: widget.selectedIndex == 8,
            onTap: () => widget.onTap(8),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Color(0xFF4CAF50), width: 1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isSelected ? Color(0xFF4CAF50) : Colors.grey),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
