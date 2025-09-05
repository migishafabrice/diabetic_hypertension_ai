import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/provider/authProvider.dart';
import 'package:healthapp/provider/bloodpressureProvider.dart';
import 'package:healthapp/widgets/app_bottom_nav.dart';
import 'package:healthapp/widgets/components.dart';
import 'package:healthapp/widgets/datePicker.dart';
import 'package:intl/intl.dart';

class BloodPressureEntry extends ConsumerStatefulWidget {
  const BloodPressureEntry({super.key});

  @override
  ConsumerState<BloodPressureEntry> createState() => _BloodPressureEntryState();
}

class _BloodPressureEntryState extends ConsumerState<BloodPressureEntry> {
  int _selectedIndex = 1; // Health tab as active by default
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  final _keyFormState = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // Load data when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBloodPressureData();
    });
  }

  Future<void> _deleteBloodPressureEntry(int entryId) async {
    try {
      setState(() => _isLoading = true);
      await ref
          .read(bloodPressureProvider.notifier)
          .deleteBloodPressureEntry(entryId);
      Components.showErrorSnackBar(
        context,
        'Blood Pressure Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      Components.showErrorSnackBar(
        context,
        'Failed to delete entry: $e',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBloodPressureData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(bloodPressureProvider.notifier)
            .getBloodPressureEntries(user.id);
      } catch (e) {
        Components.showErrorSnackBar(
          context,
          'Failed to load data: $e',
          Icons.error,
          Colors.red,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

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
    final user = ref.watch(authProvider);
    final records = ref.watch(bloodPressureProvider);
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    TimeOfDay currentTime = TimeOfDay.now();
    _timeController.text = currentTime.format(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHistory(nameOfPage: 'Blood Pressure', userData: {}),
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              key: _keyFormState,
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
                          controller: _systolicController,
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
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'Systolic must be a valid integer';
                            }
                            // Valid
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _diastolicController,
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
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'Diastolic must be a valid integer';
                            }
                            // Valid
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _pulseController,
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
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'Pulse must be a valid integer';
                            }
                            // Valid
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: _noteController,
                    maxLines: null,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Note',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Note must not be empty';
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          onTap: () =>
                              Datepicker.selectDate(context, _dateController),
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
                          controller: _timeController,
                          onTap: () =>
                              Datepicker.selectTime(context, _timeController),
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
                      onPressed: () async {
                        if (_keyFormState.currentState!.validate()) {
                          int userId = user!.id;

                          TimeOfDay parseTimeFromController() {
                            if (_timeController.text.isEmpty ||
                                !_timeController.text.contains(':')) {
                              return TimeOfDay.now();
                            }

                            String timeString = _timeController.text.trim();

                            try {
                              // Parse AM/PM format
                              final format = DateFormat(
                                'h:mm a',
                              ); // Handles "12:30 PM"
                              final dateTime = format.parse(timeString);
                              return TimeOfDay.fromDateTime(dateTime);
                            } catch (e) {
                              // Fallback to current time if parsing fails
                              return TimeOfDay.now();
                            }
                          }

                          NewBloodPressureEntry entry = NewBloodPressureEntry(
                            userId: userId,
                            systolic: int.parse(_systolicController.text),
                            diastolic: int.parse(_diastolicController.text),
                            pulse: int.parse(_pulseController.text),
                            note: _noteController.text,
                            entryDate: _dateController.text.isNotEmpty
                                ? DateTime.parse(_dateController.text)
                                : DateTime.now(),
                            entryTime: parseTimeFromController(),
                          );
                          try {
                            setState(() => _isLoading = true);
                            await ref
                                .read(bloodPressureProvider.notifier)
                                .addBloodPressureEntry(entry);
                            Components.showErrorSnackBar(
                              context,
                              'Blood Pressure Entry Added Successfully',
                              Icons.check_circle,
                              Colors.green,
                            );

                            _systolicController.clear();
                            _diastolicController.clear();
                            _pulseController.clear();
                            _noteController.clear();
                            _dateController.clear();
                            _timeController.clear();
                            await ref
                                .read(bloodPressureProvider.notifier)
                                .getBloodPressureEntries(userId);
                          } catch (e) {
                            Components.showErrorSnackBar(
                              context,
                              'Failed to add entry: $e',
                              Icons.error,
                              Colors.red,
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
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
                  SizedBox(height: 20),
                  Divider(color: Colors.black, thickness: 1),
                  Center(
                    child: Text(
                      'History of Blood Pressure records',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: Colors.black, thickness: 1),
                  // Replace the entire history section with this code
                  // Replace the history section with this code
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height:
                        MediaQuery.of(context).size.height *
                        0.3, // Fixed height constraint
                    child: records.isEmpty
                        ? _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'No blood pressure records found.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  trailing: SizedBox(
                                    width: 40,
                                    child: Container(
                                      width: 40,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.edit,
                                                size: 25,
                                                color: Colors.blue[700],
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () => {
                                                _deleteBloodPressureEntry(
                                                  record.id!,
                                                ),
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                size: 25,
                                                color: Colors.deepOrange,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'BP: ${record.systolic}/${record.diastolic} mmHg\nPulse: ${record.pulse} bpm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Note: ${record.note}\nDate: ${DateFormat('yyyy-MM-dd').format(record.entryDate)}       Time: ${record.entryTime.format(context)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
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
  int _selectedIndex = 2;
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeControlloer = TextEditingController();
  String? _selectedValue;
  String? _selectedTime;

  final times = [
    '---Select Time---',
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Other',
  ];
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
          CommonHistory(nameOfPage: 'Blood Sugar', userData: {}),
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
                            groupValue: _selectedValue,
                            onChanged: (value) {
                              setState(() {
                                _selectedValue = value;
                              });
                            },
                          ),
                        ),
                      ),

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
                            groupValue: _selectedValue,
                            onChanged: (value) {
                              setState(() {
                                _selectedValue = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedValue == "Random")
                    DropdownButtonFormField<String>(
                      menuMaxHeight: 200,
                      isDense: true,
                      alignment: Alignment.centerLeft,

                      value: _selectedTime,

                      items: times
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTime = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Time',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

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

class CommonHistory extends ConsumerWidget {
  final String nameOfPage;
  final Map<String, dynamic> userData;
  const CommonHistory({required this.nameOfPage, required this.userData});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
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
                  icon: Icon(Icons.person, color: Colors.blue[700], size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(user!.nickname),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: Colors.black),
                              SizedBox(height: 8),
                              Text('Username: ${user.username}'),
                              SizedBox(height: 8),
                              Text('Function: ${user.function}'),
                              SizedBox(height: 8),
                              Text('Address: ${user.address}'),
                              SizedBox(height: 8),
                              Text(
                                'Birthdate: ${user.birthdate.toLocal().toString().split(' ')[0]}',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
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
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.blue[700], size: 20),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, '/Login');
                  },
                ),
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
          CommonHistory(nameOfPage: 'Medication', userData: {}),
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
          CommonHistory(nameOfPage: 'Physical Exercise', userData: {}),
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
            CommonHistory(nameOfPage: 'Food Intake', userData: {}),
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
