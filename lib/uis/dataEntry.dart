import 'package:flutter/material.dart';
import 'package:healthapp/widgets/app_bottom_nav.dart';

class BloodPressureEntry extends StatefulWidget {
  const BloodPressureEntry({super.key});

  @override
  State<BloodPressureEntry> createState() => _BloodPressureEntryState();
}

class _BloodPressureEntryState extends State<BloodPressureEntry> {
  int _selectedIndex = 1; // Health tab as active by default

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHistory(nameOfPage: 'Blood Pressure'),
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'New Record',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Systolic',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Diastolic',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Pulse',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    maxLines: null,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: 400,
                        height: 50,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 100,
                            right: 100,
                            top: 5,
                          ),
                          child: Icon(Icons.save, size: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class BloodSugarEntry extends StatefulWidget {
  const BloodSugarEntry({super.key});

  @override
  State<BloodSugarEntry> createState() => _BloodSugarEntryState();
}

class _BloodSugarEntryState extends State<BloodSugarEntry> {
  int _selectedIndex = 2; // Health tab as active by default

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHistory(nameOfPage: 'Blood Sugar'),
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'New Record',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'Random',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Radio(
                            value: 'Random',
                            groupValue: null,
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'H1Ac',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Radio(
                            value: 'H1Ac',
                            groupValue: null,
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Level',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    maxLines: null,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: 400,
                        height: 50,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 100,
                            right: 100,
                            top: 5,
                          ),
                          child: Icon(Icons.save, size: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class CommonHistory extends StatelessWidget {
  final String nameOfPage;
  const CommonHistory({super.key, required this.nameOfPage});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 60,
            left: 20,
            right: 20,
            bottom: 30,
          ),
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
                radius: 24,
                backgroundColor: Colors.blue[700]!.withOpacity(0.1),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_left,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
              Text(
                nameOfPage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[700]!.withOpacity(0.1),
                child: Icon(Icons.person, color: Colors.blue[700], size: 20),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     _buildCard(context, 'Lowest Ever', '50/40 P:57', Colors.red),
        //     _buildCard(context, 'Best Ever', '110/72 P:57', Colors.green),
        //     _buildCard(context, 'Highest Ever', '180/110 P:57', Colors.red),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationEntry extends StatefulWidget {
  const MedicationEntry({super.key});

  @override
  State<MedicationEntry> createState() => _MedicationEntryState();
}

class _MedicationEntryState extends State<MedicationEntry> {
  String? _frequency;
  int _selectedIndex = 5; // Health tab as active by default

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHistory(nameOfPage: 'Medication'),
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'New Record',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Medication Name',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Dosage (e.g., 500 mg)',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _frequency,
                    items: const [
                      DropdownMenuItem(value: 'Once', child: Text('Once')),
                      DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                      DropdownMenuItem(
                        value: 'Twice Daily',
                        child: Text('Twice Daily'),
                      ),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                        value: 'Monthly',
                        child: Text('Monthly'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _frequency = val),
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    maxLines: null,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: 400,
                        height: 50,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 100,
                            right: 100,
                            top: 5,
                          ),
                          child: Icon(Icons.save, size: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class PhysicalExerciseEntry extends StatefulWidget {
  const PhysicalExerciseEntry({super.key});

  @override
  State<PhysicalExerciseEntry> createState() => _PhysicalExerciseEntryState();
}

class _PhysicalExerciseEntryState extends State<PhysicalExerciseEntry> {
  String? _intensity;
  int _selectedIndex = 4; // Health tab as active by default

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic here. Example:
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHistory(nameOfPage: 'Physical Exercise'),
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'New Record',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Exercise Type',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Duration (minutes)',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _intensity,
                          items: const [
                            DropdownMenuItem(value: 'Low', child: Text('Low')),
                            DropdownMenuItem(
                              value: 'Moderate',
                              child: Text('Moderate'),
                            ),
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High'),
                            ),
                          ],
                          onChanged: (val) => setState(() => _intensity = val),
                          decoration: InputDecoration(
                            labelText: 'Intensity',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Calories Burned (optional)',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    maxLines: null,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: 400,
                        height: 50,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 100,
                            right: 100,
                            top: 5,
                          ),
                          child: Icon(Icons.save, size: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class FoodIntakeEntry extends StatefulWidget {
  const FoodIntakeEntry({super.key});

  @override
  State<FoodIntakeEntry> createState() => _FoodIntakeEntryState();
}

class _FoodIntakeEntryState extends State<FoodIntakeEntry> {
  int _selectedIndex = 3; // Health tab as active by default

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CommonHistory(nameOfPage: 'Food Intake'),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'New Record',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Food Description',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Time',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const SizedBox(
                          width: 400,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 100,
                              right: 100,
                              top: 5,
                            ),
                            child: Icon(Icons.save, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
