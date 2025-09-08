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
  OverlayEntry? _medicationMenu;

  void _showMedicationPopup(BuildContext context, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _medicationMenu = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Dismiss area
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideMedicationPopup,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Popup menu
            Positioned(
              left: offset.dx + size.width / 2 - 90,
              bottom: MediaQuery.of(context).size.height - offset.dy,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    // Popup box
                    Container(
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add),
                            title: const Text('New Medication'),
                            onTap: () {
                              _hideMedicationPopup();
                              widget.onTap(100);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: const Text('Medication Intake'),
                            onTap: () {
                              _hideMedicationPopup();
                              widget.onTap(101);
                            },
                          ),
                        ],
                      ),
                    ),
                    // Triangle
                    CustomPaint(
                      size: const Size(24, 12),
                      painter: _TrianglePainter(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_medicationMenu!);
  }

  void _hideMedicationPopup() {
    _medicationMenu?.remove();
    _medicationMenu = null;
  }

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItem(
            icon: CupertinoIcons.home,
            label: 'Home',
            isSelected: widget.selectedIndex == 0,
            onTap: () => widget.onTap(0),
          ),
          BottomNavItem(
            icon: CupertinoIcons.heart,
            label: 'Hearth',
            isSelected: widget.selectedIndex == 1,
            onTap: () => widget.onTap(1),
          ),
          BottomNavItem(
            icon: CupertinoIcons.drop,
            label: 'Diabetes',
            isSelected: widget.selectedIndex == 2,
            onTap: () => widget.onTap(2),
          ),
          BottomNavItem(
            icon: Icons.fastfood,
            label: 'Food',
            isSelected: widget.selectedIndex == 3,
            onTap: () => widget.onTap(3),
          ),
          BottomNavItem(
            icon: Icons.directions_run,
            label: 'Activity',
            isSelected: widget.selectedIndex == 4,
            onTap: () => widget.onTap(4),
          ),
          BottomNavItem(
            key: _medicationKey,
            icon: Icons.medical_services,
            label: 'Medication',
            isSelected: widget.selectedIndex == 5,
            onTap: () {
              widget.onTap(5);
              if (_medicationMenu == null) {
                _showMedicationPopup(context, _medicationKey);
              } else {
                _hideMedicationPopup();
              }
            },
          ),
          BottomNavItem(
            icon: Icons.report,
            label: 'Reports',
            isSelected: widget.selectedIndex == 6,
            onTap: () => widget.onTap(6),
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

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawShadow(path, Colors.black26, 4, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}
