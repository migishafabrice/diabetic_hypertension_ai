import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:healthapp/provider/authProvider.dart';
import 'package:healthapp/provider/bloodSugarProvider.dart';
import 'package:healthapp/provider/bloodpressureProvider.dart';
import 'package:healthapp/provider/exerciseProvider.dart';
import 'package:healthapp/provider/foodProvider.dart';
import 'package:healthapp/provider/medicationIntakeProvider.dart';
import 'package:healthapp/provider/medicationProvider.dart';
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
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
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
      showErrorSnackBar(
        context,
        'Blood Pressure Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      showErrorSnackBar(
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
        showErrorSnackBar(
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
    dashboardWidget(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final records = ref.watch(bloodPressureProvider);
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    TimeOfDay currentTime = TimeOfDay.now();
    _timeController.text = currentTime.format(context);
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
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
                              return null;
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
                              return null;
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
                              return null;
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                        return null;
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
                              showErrorSnackBar(
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
                              showErrorSnackBar(
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
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class BloodSugarEntry extends ConsumerStatefulWidget {
  const BloodSugarEntry({super.key});

  @override
  ConsumerState<BloodSugarEntry> createState() => _BloodSugarEntryState(); // This line is causing the error
}

class _BloodSugarEntryState extends ConsumerState<BloodSugarEntry> {
  int _selectedIndex = 2;
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedValue;
  String? _selectedTime;
  String? _selectedUnit;
  bool _isLoading = false;
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
  @override
  void initState() {
    super.initState();
    // Load data when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBloodSugarData();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  Future<void> _loadBloodSugarData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(bloodSugarProvider.notifier)
            .getBloodSugarEntries(user.id);
      } catch (e) {
        showErrorSnackBar(
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

  Future<void> _deleteBloodSugarEntry(int entryId) async {
    try {
      setState(() => _isLoading = true);
      await ref
          .read(bloodSugarProvider.notifier)
          .deleteBloodSugarEntry(entryId);
      showErrorSnackBar(
        context,
        'Blood Sugar Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      showErrorSnackBar(
        context,
        'Failed to delete entry: $e',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final records = ref.watch(bloodSugarProvider);
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    TimeOfDay currentTime = TimeOfDay.now();
    _timeController.text = currentTime.format(context);
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            CommonHistory(nameOfPage: 'Blood Sugar', userData: {}),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
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
                              'H1AC',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: Radio(
                              value: 'H1AC',
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
                    if (_selectedValue == "Random") ...[
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
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            items: const [
                              DropdownMenuItem(
                                value: 'mg/dL',
                                child: Text('mg/dL'),
                              ),
                              DropdownMenuItem(
                                value: 'mmol/L',
                                child: Text('mmol/L'),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedUnit = val),
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _levelController,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Level',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            validator: (value) {
                              if (_selectedValue == null) {
                                return 'Please select type of measurement.';
                              } else if (_selectedValue == "Random" &&
                                  (_selectedTime == null ||
                                      _selectedTime == '---Select Time---')) {
                                return 'Please select a time for Random measurement.';
                              } else if (_selectedUnit == null) {
                                return 'Please select a unit.';
                              } else if (value == null || value.isEmpty) {
                                return 'Level cannot be empty.';
                              } else if (double.tryParse(value) == null) {
                                return 'Level must be a valid number.';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _noteController,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Note must not be empty'
                          : null,
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            newBloodSugarEntry entry = newBloodSugarEntry(
                              userId: user!.id,
                              type: _selectedValue!,
                              mealRelation: _selectedTime ?? 'Other',
                              sugarLevel: double.parse(_levelController.text),
                              note: _noteController.text,
                              entryDate: _dateController.text.isNotEmpty
                                  ? DateTime.parse(_dateController.text)
                                  : DateTime.now(),
                              entryTime: TimeOfDay.now(),
                              unit: _selectedUnit!,
                            );
                            ref
                                .read(bloodSugarProvider.notifier)
                                .addBloodSugarEntry(entry);
                            showErrorSnackBar(
                              context,
                              'Blood Sugar Entry Added Successfully',
                              Icons.check_circle,
                              Colors.green,
                            );
                            _levelController.clear();
                            _noteController.clear();
                            _dateController.clear();
                            _timeController.clear();
                            _selectedTime = null;
                            _selectedUnit = null;
                            _selectedValue = null;
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
                        'History of Blood Sugar records',
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
                          0.25, // Fixed height constraint
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
                                                  _deleteBloodSugarEntry(
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
                                      'Level: ${record.sugarLevel} ${record.unit}\nType: ${record.type} (${record.mealRelation})',
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
  const CommonHistory({
    super.key,
    required this.nameOfPage,
    required this.userData,
  });
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

class MedicationEntry extends ConsumerStatefulWidget {
  const MedicationEntry({super.key});

  @override
  ConsumerState<MedicationEntry> createState() => _MedicationEntryState();
}

class _MedicationEntryState extends ConsumerState<MedicationEntry>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 5;
  late TabController _tabController;
  final TextEditingController _medicationName = TextEditingController();
  final TextEditingController _dosageTaken = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _time = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final TextEditingController _medicationNameIntake = TextEditingController();
  final TextEditingController _dosageTakenIntake = TextEditingController();
  final TextEditingController _dateIntake = TextEditingController();
  final TextEditingController _timeIntake = TextEditingController();
  final TextEditingController _noteIntake = TextEditingController();
  final TextEditingController _medicationType = TextEditingController();
  int _medicationIndex = 0;
  int _frequency = 1;
  String session = 'Other';
  final _formKey = GlobalKey<FormState>();
  final _formKeyIntake = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingIntake = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration.zero,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMedicationData();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicationData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(medicationProvider.notifier)
            .getMedicationEntries(user.id);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error medication: $e');
        showErrorSnackBar(
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

  Future<void> _deleteMedicationEntry(int entryId) async {
    try {
      setState(() => _isLoading = true);
      await ref
          .read(medicationProvider.notifier)
          .deleteMedicationEntry(entryId);
    } catch (e) {
      setState(() => _isLoading = false);
      showErrorSnackBar(
        context,
        'Failed to delete entry',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _date.text = DateTime.now().toLocal().toString().split(' ')[0];
    _time.text = TimeOfDay.now().format(context);
    return Scaffold(
      body: Column(
        children: [
          CommonHistory(nameOfPage: 'Medication', userData: {}),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue[700],
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.blue[700],
            tabs: const [
              Tab(text: 'Medication Intake'),
              Tab(text: 'New Medication'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_newMedicationIntakeTab(), _newMedicationTab()],
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

  Widget _newMedicationIntakeTab() {
    final user = ref.watch(authProvider);
    final records = ref.watch(medicationProvider);
    //var items;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _formKeyIntake,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Record Medication Intake',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            TypeAheadField(
              controller: _medicationNameIntake,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(
                    suggestion.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  contentPadding: EdgeInsets.only(
                    left: 30.0,
                    top: 0,
                    bottom: 0.0,
                    right: 5.0,
                  ),
                );
              },
              onSelected: (suggestion) {
                _medicationNameIntake.text = suggestion.toString();
                // Split the suggestion and compare each value with the record fields
                List<String> parts = suggestion.toString().split(' | ');
                int idx = records.indexWhere(
                  (med) =>
                      parts.length == 3 &&
                      med.medicationName == parts[0] &&
                      med.medicationType == parts[1] &&
                      med.dosage == parts[2],
                );
                if (idx != -1) {
                  _medicationIndex = records[idx].id;
                }
              },
              suggestionsCallback: (pattern) async {
                return records
                    .where(
                      (med) =>
                          ('${med.medicationName} | ${med.medicationType} | ${med.dosage}')
                              .toLowerCase()
                              .contains(pattern.toLowerCase()),
                    )
                    .map(
                      (med) =>
                          ('${med.medicationName} | ${med.medicationType} | ${med.dosage}'),
                    )
                    .toList();
              },
              builder: (context, controller, focusNode) {
                return TextFormField(
                  controller: _medicationNameIntake,
                  focusNode: focusNode,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: session,
                    items: const [
                      DropdownMenuItem(
                        value: 'Morning',
                        child: Text('Morning'),
                      ),
                      DropdownMenuItem(value: 'Noon', child: Text('Noon')),
                      DropdownMenuItem(
                        value: 'Evening',
                        child: Text('Evening'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        session = val!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Session',
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
                    controller: _dosageTakenIntake,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Quantity Taken',
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
              controller: _noteIntake,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Note',
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
                    controller: _dateIntake,
                    onTap: () => Datepicker.selectDate(context, _dateIntake),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    controller: _timeIntake,
                    onTap: () => Datepicker.selectTime(context, _timeIntake),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    if (_formKeyIntake.currentState!.validate()) {
                      NewMedicationIntakeEntry entry = NewMedicationIntakeEntry(
                        id: 0,
                        userId: user!.id,
                        medicationId: _medicationIndex,
                        dosageTaken: _dosageTakenIntake.text,
                        session: session,
                        note: _noteIntake.text,
                        entryDate: _dateIntake.text.isNotEmpty
                            ? DateTime.parse(_dateIntake.text)
                            : DateTime.now(),
                        entryTime: TimeOfDay.now(),
                      );
                      if (await ref
                          .read(medicationIntakeProvider.notifier)
                          .addNewMedicationIntakeEntry(entry)) {
                        showErrorSnackBar(
                          context,
                          'Medication Intake Entry Added Successfully',
                          Icons.check_circle,
                          Colors.green,
                        );
                      } else {
                        showErrorSnackBar(
                          context,
                          'Failed to add medication intake entry',
                          Icons.error,
                          Colors.red,
                        );
                      }
                      _medicationNameIntake.clear();
                      _medicationIndex = 0;
                      _dosageTakenIntake.clear();
                      _noteIntake.clear();
                    }
                  } catch (e) {
                    print('Error adding medication intake entry: $e');
                    setState(() {
                      _isLoadingIntake = false;
                    });
                    showErrorSnackBar(
                      context,
                      e.toString(),
                      Icons.error,
                      Colors.red,
                    );
                  } finally {
                    setState(() {
                      _isLoadingIntake = false;
                    });
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
                    padding: EdgeInsets.only(left: 100, right: 100, top: 5),
                    child: Icon(Icons.save, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newMedicationTab() {
    final user = ref.watch(authProvider);
    final records = ref.watch(medicationProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Add New Medication',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _medicationName,
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _medicationType,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Medication Type',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _dosageTaken,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Dosage (e.g., 500 mg)',
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
            DropdownButtonFormField<String>(
              value: _frequency.toString(),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Once Daily')),
                DropdownMenuItem(value: '2', child: Text('Twice Daily')),
                DropdownMenuItem(value: '3', child: Text('Three times Daily')),
                DropdownMenuItem(value: '7', child: Text('Weekly')),
                DropdownMenuItem(value: '30', child: Text('Monthly')),
                DropdownMenuItem(value: '100', child: Text('Other')),
              ],
              onChanged: (val) {
                setState(() => _frequency = int.parse(val!));
              },
              decoration: InputDecoration(
                labelText: 'Frequency',
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _note,
              maxLines: null,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Note',
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      NewMedicationEntry entry = NewMedicationEntry(
                        id: 0,
                        userId: user!.id,
                        medicationName: _medicationName.text,
                        medicationType: _medicationType.text,
                        dosage: _dosageTaken.text,
                        frequency: _frequency,
                        note: _note.text,
                        active: true,
                      );
                      if (await ref
                          .read(medicationProvider.notifier)
                          .addMedicationEntry(entry)) {
                        showErrorSnackBar(
                          context,
                          'Medication Entry Added Successfully',
                          Icons.check_circle,
                          Colors.green,
                        );
                      } else {
                        showErrorSnackBar(
                          context,
                          'Failed to add medication entry',
                          Icons.error,
                          Colors.red,
                        );
                      }
                      _medicationName.clear();
                      _dosageTaken.clear();
                      _frequency = 1;
                      _note.clear();
                    }
                  } catch (e) {
                    print('Error adding medication entry: $e');
                    setState(() {
                      _isLoading = false;
                    });
                    showErrorSnackBar(
                      context,
                      'Failed to add medication entry: $e',
                      Icons.error,
                      Colors.red,
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
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
                    padding: EdgeInsets.only(left: 100, right: 100, top: 5),
                    child: Icon(Icons.save, size: 32),
                  ),
                ),
              ),
            ),
            Divider(color: Colors.black, thickness: 1),
            Center(
              child: Text(
                'History of Medication records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: Colors.black, thickness: 1),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height:
                  MediaQuery.of(context).size.height *
                  0.2, // Fixed height constraint
              child: records.isEmpty
                  ? _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No medication records found.',
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                          _deleteMedicationEntry(record.id),
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
                              'Medication Name: ${record.medicationName}\nDosage: ${record.dosage}\nFrequency: ${record.frequency}\nType: ${record.medicationType}',
                            ),
                            subtitle: Text(
                              'Note: ${record.note}',
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
    );
  }
}

class PhysicalExerciseEntry extends ConsumerStatefulWidget {
  const PhysicalExerciseEntry({super.key});

  @override
  ConsumerState<PhysicalExerciseEntry> createState() =>
      _PhysicalExerciseEntryState();
}

class _PhysicalExerciseEntryState extends ConsumerState<PhysicalExerciseEntry> {
  String? _intensity;
  int _selectedIndex = 4;
  final TextEditingController _exerciseTypeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  void initState() {
    super.initState();
    // Load data when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExerciseData();
    });
  }

  Future<void> _loadExerciseData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      try {
        await ref.read(exerciseProvider.notifier).getExerciseEntries(user.id);
      } catch (e) {
        print(e);
        showErrorSnackBar(
          context,
          'Failed to load data: $e',
          Icons.error,
          Colors.red,
        );
      }
    }
  }

  Future<void> _deleteExerciseEntry(int entryId) async {
    try {
      await ref.read(exerciseProvider.notifier).deleteExerciseEntry(entryId);
      showErrorSnackBar(
        context,
        'Exercise Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      showErrorSnackBar(
        context,
        'Error deleting exercise entry: $e',
        Icons.error,
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final exercises = ref.watch(exerciseProvider);
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            CommonHistory(nameOfPage: 'Physical Exercise', userData: {}),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
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
                          child: TypeAheadField(
                            controller: _exerciseTypeController,
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.toString()),
                              );
                            },
                            onSelected: (suggestion) {
                              _exerciseTypeController.text = suggestion
                                  .toString();
                            },
                            suggestionsCallback: (pattern) async {
                              // Return your suggestions here
                              return [];
                            },
                            builder: (context, controller, focusNode) {
                              return TextFormField(
                                controller: _exerciseTypeController,
                                focusNode: focusNode,
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
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
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
                            validator: (value) =>
                                value == null ||
                                    value.isEmpty ||
                                    int.tryParse(value) == null
                                ? 'Duration cannot be a number'
                                : null,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _intensity,
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Moderate',
                          child: Text('Moderate'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
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
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _noteController,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Note',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      validator: (value) =>
                          (value!.isEmpty) ? 'Note must not be empty' : null,
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
                          try {
                            if (_formKey.currentState!.validate()) {
                              NewExerciseEntry entry = NewExerciseEntry(
                                userId: user!.id,
                                exerciseType: _exerciseTypeController.text,
                                duration: int.parse(_durationController.text),
                                intensity: _intensity ?? 'Moderate',
                                note: _noteController.text,
                                entryDate: DateTime.now(),
                                entryTime:
                                    TimeOfDay.now(), // This line is causing the error
                              );
                              if (await ref
                                  .read(exerciseProvider.notifier)
                                  .addExerciseEntry(entry)) {
                                showErrorSnackBar(
                                  context,
                                  'Exercise Entry Added Successfully',
                                  Icons.check_circle,
                                  Colors.green,
                                );
                              } else {
                                showErrorSnackBar(
                                  context,
                                  'Failed to add exercise entry',
                                  Icons.error,
                                  Colors.red,
                                );
                              }
                              _exerciseTypeController.clear();
                              _durationController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              _noteController.clear();
                              _intensity = null;
                            }
                          } catch (e) {
                            print(e);
                            showErrorSnackBar(
                              context,
                              'Error: $e',
                              Icons.error,
                              Colors.red,
                            );
                          } finally {
                            _loadExerciseData();
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.black, thickness: 1),
            Center(
              child: Text(
                'History of Physical Exercise records',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(color: Colors.black, thickness: 1),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.of(context).size.height * 0.25,
              child: exercises.isEmpty
                  ? _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No exercise records found.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final record = exercises[index];
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                          _deleteExerciseEntry(
                                            exercises[index].id!,
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
                              '${record.exerciseType} - ${record.duration} mins - Intensity: ${record.intensity}'
                              '\nNote: ${record.note}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              // This line is causing the error
                              'Date: ${DateFormat('yyyy-MM-dd').format(record.entryDate)}       Time: ${record.entryTime.format(context)}',
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
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class FoodIntakeEntry extends ConsumerStatefulWidget {
  const FoodIntakeEntry({super.key});

  @override
  ConsumerState<FoodIntakeEntry> createState() => _FoodIntakeEntryState();
}

class _FoodIntakeEntryState extends ConsumerState<FoodIntakeEntry> {
  int _selectedIndex = 3; // Health tab as active by default
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFoodEntries();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  Future<void> _deleteFoodEntry(int entryId) async {
    try {
      await ref.read(foodProvider.notifier).deleteFoodEntry(entryId);
      showErrorSnackBar(
        context,
        'Food Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      print(e);
      showErrorSnackBar(
        context,
        'Error deleting food entry: $e',
        Icons.error,
        Colors.red,
      );
    }
  }

  Future<void> _loadFoodEntries() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = ref.read(authProvider);
      if (user != null) {
        await ref.read(foodProvider.notifier).getFoodEntries(user.id);
      }
    } catch (e) {
      showErrorSnackBar(
        context,
        'Failed to load food record',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final foodEntries = ref.watch(foodProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                        controller: _foodController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter food description';
                          }
                          return null;
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Food Description',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      SizedBox(height: 10),
                      TextFormField(
                        controller: _noteController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a note';
                          }
                          return null;
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Note',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              onTap: () => Datepicker.selectDate(
                                context,
                                _dateController,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                              readOnly: true,
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
                              controller: _timeController,
                              readOnly: true,
                              onTap: () => Datepicker.selectTime(
                                context,
                                _timeController,
                              ),
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
                          onPressed: () async {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                NewFoodEntry entry = NewFoodEntry(
                                  id: 0,
                                  userId:
                                      user!.id, // Replace with actual user ID
                                  food_description: _foodController.text,
                                  note: _noteController.text,
                                  entryDate: DateTime.now(),
                                  entryTime: TimeOfDay.now(),
                                );
                                if (await ref
                                    .read(foodProvider.notifier)
                                    .addFoodEntry(entry)) {
                                  showErrorSnackBar(
                                    context,
                                    'Food Intake Entry added Successfully',
                                    Icons.check_circle,
                                    Colors.green,
                                  );
                                } else {
                                  showErrorSnackBar(
                                    context,
                                    'Food Intake Entry failed',
                                    Icons.error,
                                    Colors.red,
                                  );
                                }
                                _foodController.clear();
                                _noteController.clear();
                                _dateController.clear();
                                _timeController.clear();
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              print(e);
                              showErrorSnackBar(
                                context,
                                "$e",
                                Icons.error,
                                Colors.red,
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
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
                      Divider(color: Colors.black),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'History of Food Intake records',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.black),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 400,
                        child: foodEntries.isEmpty
                            ? _isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text(
                                          'No food records found.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: foodEntries.length,
                                itemBuilder: (context, index) {
                                  final record = foodEntries[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    child: ListTile(
                                      trailing: SizedBox(
                                        width: 40,
                                        child: Column(
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
                                                  _deleteFoodEntry(record.id!),
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
                                      title: Text(
                                        'Food: ${record.food_description} '
                                        '\nNote: ${record.note}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Date: ${record.entryDate.toLocal().toString().split(' ')[0]} '
                                        'Time: ${record.entryTime.format(context)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
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
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
