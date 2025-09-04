import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthapp/uis/dataEntry.dart';
import 'package:healthapp/widgets/app_bottom_nav.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const Dashboard({super.key, required this.userData});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CommonHistory(nameOfPage: 'Dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  _buildHealthOverview(),
                  _buildChartsSection(),
                  _buildStatsGrid(),
                  _buildRecentActivities(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          AppBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              _onItemTapped(index);
              // Example navigation: match previous logic
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
              } // Add other navigation as needed.
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color.fromARGB(255, 136, 194, 241)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Icon(Icons.logout, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _HealthMetricCard(
              title: 'Heart Rate',
              value: '72',
              unit: 'bpm',
              icon: CupertinoIcons.heart,
              color: Colors.red,
              trend: '+2',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HealthMetricCard(
              title: 'Blood Pressure',
              value: '120/80',
              unit: 'mmHg',
              icon: CupertinoIcons.drop,
              color: Colors.blue,
              trend: 'Normal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: _WeeklyActivityChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _StatGridItem(
            title: 'Distance',
            value: '5.2 km',
            icon: CupertinoIcons.map,
            color: Colors.green,
          ),
          _StatGridItem(
            title: 'Active Time',
            value: '1h 15m',
            icon: CupertinoIcons.clock,
            color: Colors.amber,
          ),
          _StatGridItem(
            title: 'Water',
            value: '2.1 L',
            icon: CupertinoIcons.drop,
            color: Colors.blue,
          ),
          _StatGridItem(
            title: 'BMI',
            value: '22.1',
            icon: Icons.line_weight,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              _ActivityItem(
                icon: Icons.directions_run,
                title: 'Morning Run',
                subtitle: '5.2 km • 32 min',
                time: 'Today, 7:00 AM',
                color: Colors.blue,
              ),
              _ActivityItem(
                icon: CupertinoIcons.heart,
                title: 'Heart Rate Check',
                subtitle: '72 bpm • Normal',
                time: 'Today, 12:30 PM',
                color: Colors.red,
              ),
              _ActivityItem(
                icon: CupertinoIcons.moon,
                title: 'Sleep Analysis',
                subtitle: '7h 20m • Good',
                time: 'Yesterday, 11:00 PM',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Replaced by AppBottomNavigationBar.
}

class _HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String trend;

  const _HealthMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trend == 'Normal'
                  ? Colors.green.withOpacity(0.08)
                  : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: 12,
                color: trend == 'Normal' ? Colors.green : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart();

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 60,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Mon';
                    break;
                  case 1:
                    text = 'Tue';
                    break;
                  case 2:
                    text = 'Wed';
                    break;
                  case 3:
                    text = 'Thu';
                    break;
                  case 4:
                    text = 'Fri';
                    break;
                  case 5:
                    text = 'Sat';
                    break;
                  case 6:
                    text = 'Sun';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  key: ValueKey(meta),
                  space: 8,
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == meta.min || value == meta.max) {
                  return Container();
                }
                return SideTitleWidget(
                  key: ValueKey(meta),
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  space: 8,
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 30,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 45,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 25,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 50,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 35,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 40,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(
                toY: 55,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatGridItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatGridItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

// Moved to widgets/app_bottom_nav.dart as BottomNavItem.
