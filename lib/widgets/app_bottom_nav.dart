import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItem(
            icon: CupertinoIcons.home,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          BottomNavItem(
            icon: CupertinoIcons.heart,
            label: 'Hearth',
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          BottomNavItem(
            icon: CupertinoIcons.drop,
            label: 'Diabetes',
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          BottomNavItem(
            icon: Icons.fastfood,
            label: 'Food',
            isSelected: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
          BottomNavItem(
            icon: Icons.directions_run,
            label: 'Activity',
            isSelected: selectedIndex == 4,
            onTap: () => onTap(4),
          ),
          BottomNavItem(
            icon: Icons.medical_services,
            label: 'Medication',
            isSelected: selectedIndex == 5,
            onTap: () => onTap(5),
          ),
          BottomNavItem(
            icon: Icons.report,
            label: 'Reports',
            isSelected: selectedIndex == 6,
            onTap: () => onTap(6),
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
          border: isSelected ? Border.all(color: Colors.blue, width: 1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isSelected ? Colors.blue : Colors.grey),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
