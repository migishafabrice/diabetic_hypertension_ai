import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:diacare/provider/authProvider.dart';
import 'package:diacare/provider/bloodSugarProvider.dart';
import 'package:diacare/provider/bloodPressureProvider.dart';
import 'package:diacare/provider/bodyMeasurementProvider.dart';
import 'package:diacare/provider/exerciseProvider.dart';
import 'package:diacare/provider/foodProvider.dart';
import 'package:diacare/provider/medicationIntakeProvider.dart';
import 'package:diacare/provider/medicationProvider.dart';
import 'package:diacare/provider/symptomProvider.dart';
import 'package:diacare/models/local_body_measurement.dart';
import 'package:diacare/models/local_blood_pressure.dart';
import 'package:diacare/models/local_blood_sugar.dart';
import 'package:diacare/models/local_food_intake.dart';
import 'package:diacare/models/local_physical_activity.dart';
import 'package:diacare/models/local_medication.dart';
import 'package:diacare/models/local_medication_intake.dart';
import 'package:diacare/models/local_symptom.dart';
import 'package:diacare/widgets/app_bottom_nav.dart';
import 'package:diacare/widgets/components.dart';
import 'package:diacare/widgets/datePicker.dart';
import 'package:diacare/widgets/profile_icon.dart';
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
  final _keyFormState = GlobalKey<FormState>(); // For main form
  final _editKeyFormState = GlobalKey<FormState>(); // For edit modal
  bool _isLoading = false;
  LocalBloodPressure? _editingRecord; // For edit mode

  @override
  void initState() {
    super.initState();
    // Load data when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBloodPressureData();
    });
  }

  Future<void> _deleteBloodPressureEntry(int entryId, int userId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ref
            .read(bloodPressureProvider.notifier)
            .deleteBloodPressureEntry(entryId, userId);
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
  }

  Future<void> _loadBloodPressureData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(bloodPressureProvider.notifier)
            .getBloodPressureEntries(user.id!);
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

  void _openEditModal(LocalBloodPressure record) {
    setState(() {
      _editingRecord = record;
      _systolicController.text = record.systolic.toString();
      _diastolicController.text = record.diastolic.toString();
      _pulseController.text = record.pulse?.toString() ?? '';
      _noteController.text = record.note ?? '';
      _dateController.text = record.dateTakenOn ?? '';
      _timeController.text = record.timeTakenOn ?? '';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Blood Pressure Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editKeyFormState,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _systolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Systolic',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null) {
                            return 'Systolic must be a valid integer';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Diastolic',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null) {
                            return 'Diastolic must be a valid integer';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _pulseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Pulse'),
                      ),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Note'),
                      ),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () =>
                            Datepicker.selectDate(context, _dateController),
                        decoration: const InputDecoration(labelText: 'Date'),
                      ),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: () =>
                            Datepicker.selectTime(context, _timeController),
                        decoration: const InputDecoration(labelText: 'Time'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editKeyFormState.currentState!.validate()) {
                      final updatedRecord = _editingRecord!.copyWith(
                        systolic: int.parse(_systolicController.text),
                        diastolic: int.parse(_diastolicController.text),
                        pulse: _pulseController.text.isNotEmpty
                            ? int.parse(_pulseController.text)
                            : null,
                        note: _noteController.text,
                        dateTakenOn: _dateController.text,
                        timeTakenOn: _timeController.text,
                      );

                      try {
                        await ref
                            .read(bloodPressureProvider.notifier)
                            .updateBloodPressureEntry(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _systolicController.clear();
    _diastolicController.clear();
    _pulseController.clear();
    _noteController.clear();
    _dateController.clear();
    _timeController.clear();
    setState(() {
      _editingRecord = null;
    });
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
                            int userId = user!.id!;

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

                            LocalBloodPressure entry = LocalBloodPressure(
                              userid: userId,
                              systolic: int.parse(_systolicController.text),
                              diastolic: int.parse(_diastolicController.text),
                              pulse: _pulseController.text.isNotEmpty
                                  ? int.parse(_pulseController.text)
                                  : null,
                              note: _noteController.text,
                              dateTakenOn: _dateController.text.isNotEmpty
                                  ? _dateController.text
                                  : DateTime.now()
                                        .toIso8601String()
                                        .split('T')
                                        .first,
                              timeTakenOn: _timeController.text,
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
                          backgroundColor: Colors.green[700],
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
                                      width: 60,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _openEditModal(record),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 25,
                                                color: Colors.green[700],
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _deleteBloodPressureEntry(
                                                    record.id!,
                                                    user!.id!,
                                                  ),
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
                                      'BP: ${record.systolic}/${record.diastolic} mmHg${record.pulse != null ? '\nPulse: ${record.pulse} bpm' : ''}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Note: ${record.note ?? ''}\nDate: ${record.dateTakenOn}\nTime: ${record.timeTakenOn}',
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
  final _formKey = GlobalKey<FormState>(); // For main form
  final _editFormKey = GlobalKey<FormState>(); // For edit modal
  String? _selectedValue;
  String? _selectedTime;
  String? _selectedUnit;
  bool _isLoading = false;
  LocalBloodSugar? _editingRecord;
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
            .getBloodSugarEntries(user.id!);
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

  Future<void> _deleteBloodSugarEntry(int entryId, int userId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ref
            .read(bloodSugarProvider.notifier)
            .deleteBloodSugarEntry(entryId, userId);
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
  }

  void _openEditModal(LocalBloodSugar record) {
    setState(() {
      _editingRecord = record;
      _levelController.text = record.level.toString();
      _noteController.text = record.note ?? '';
      _dateController.text = record.dateTakenOn ?? '';
      _timeController.text = record.timeTakenOn ?? '';
      _selectedValue = record.typeMeasurement;
      _selectedTime = record.mealRelation;
      _selectedUnit = record.unit;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Blood Sugar Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text(
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
                                  setDialogState(() {
                                    _selectedValue = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text(
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
                                  setDialogState(() {
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
                          value: _selectedTime,
                          items: times
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedTime = value;
                            });
                          },
                          decoration: const InputDecoration(
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
                              onChanged: (val) => setDialogState(() {
                                _selectedUnit = val;
                              }),
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _levelController,
                              decoration: const InputDecoration(
                                labelText: 'Level',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _timeController,
                              decoration: const InputDecoration(
                                labelText: 'Time',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      final updatedRecord = _editingRecord!.copyWith(
                        typeMeasurement: _selectedValue,
                        mealRelation: _selectedTime ?? 'Other',
                        level: double.parse(_levelController.text),
                        note: _noteController.text,
                        dateTakenOn: _dateController.text,
                        timeTakenOn: _timeController.text,
                        unit: _selectedUnit,
                      );
                      try {
                        await ref
                            .read(bloodSugarProvider.notifier)
                            .updateBloodSugarEntry(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _levelController.clear();
    _noteController.clear();
    _dateController.clear();
    _timeController.clear();
    setState(() {
      _editingRecord = null;
      _selectedValue = null;
      _selectedTime = null;
      _selectedUnit = null;
    });
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            LocalBloodSugar entry = LocalBloodSugar(
                              userid: user!.id!,
                              typeMeasurement: _selectedValue,
                              mealRelation: _selectedTime ?? 'Other',
                              level: double.parse(_levelController.text),
                              note: _noteController.text,
                              dateTakenOn: _dateController.text.isNotEmpty
                                  ? _dateController.text
                                  : DateTime.now().toIso8601String().split(
                                      'T',
                                    )[0],
                              timeTakenOn: _timeController.text,
                              unit: _selectedUnit,
                            );
                            try {
                              setState(() => _isLoading = true);
                              await ref
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
                              setState(() {
                                _selectedTime = null;
                                _selectedUnit = null;
                                _selectedValue = null;
                              });
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
                          backgroundColor: Colors.green[700],
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
                                        'No blood sugar records found.',
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
                                      width: 60,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _openEditModal(record),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 25,
                                                color: Colors.green[700],
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _deleteBloodSugarEntry(
                                                    record.id!,
                                                    user!.id!,
                                                  ),
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
                                      'Level: ${record.level} ${record.unit}\nType: ${record.typeMeasurement} (${record.mealRelation})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Note: ${record.note ?? ''}\nDate: ${record.dateTakenOn}\nTime: ${record.timeTakenOn}',
                                      style: const TextStyle(fontSize: 14),
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
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF4CAF50), Color(0xFF8BC34A), Colors.white],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
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
                backgroundColor: Colors.green[700]!.withOpacity(0.1),
                child: ProfileIcon(iconColor: Colors.green[700]),
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
                backgroundColor: Colors.green[700]!.withOpacity(0.1),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.green[700], size: 20),
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
  final _editFormKey = GlobalKey<FormState>();
  final _editIntakeFormKey = GlobalKey<FormState>();
  int _medicationIndex = 0;
  int _frequency = 1;
  String session = 'Other';
  final _formKey = GlobalKey<FormState>();
  final _formKeyIntake = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingIntake = false;
  LocalMedication? _editingMedication;
  LocalMedicationIntake? _editingMedicationIntake;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration.zero,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.watch(authProvider);
    if (user != null) {
      _loadMedicationData();
      _loadMedicationIntakeData();
    }
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
            .getMedicationEntries(user.id!);
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

  Future<void> _loadMedicationIntakeData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoadingIntake = true);
      try {
        await ref
            .read(medicationIntakeProvider.notifier)
            .getMedicationIntakeEntries(user.id!);
      } catch (e) {
        setState(() {
          _isLoadingIntake = false;
        });
        print('Error medication intake: $e');
        showErrorSnackBar(
          context,
          'Failed to load data: $e',
          Icons.error,
          Colors.red,
        );
      } finally {
        setState(() => _isLoadingIntake = false);
      }
    }
  }

  Future<void> _deleteMedicationEntry(int entryId, int userId) async {
    try {
      setState(() => _isLoading = true);
      await ref
          .read(medicationProvider.notifier)
          .deleteMedicationEntry(entryId, userId);
      showErrorSnackBar(
        context,
        'Medication Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      showErrorSnackBar(
        context,
        'Failed to delete entry: $e',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedicationIntakeEntry(int entryId, int userId) async {
    try {
      setState(() => _isLoadingIntake = true);
      await ref
          .read(medicationIntakeProvider.notifier)
          .deleteMedicationIntakeEntry(entryId, userId);
      showErrorSnackBar(
        context,
        'Medication Intake Entry Deleted Successfully',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      setState(() => _isLoadingIntake = false);
      showErrorSnackBar(
        context,
        'Failed to delete entry: $e',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoadingIntake = false;
      });
    }
  }

  void _openEditMedicationModal(LocalMedication record) {
    setState(() {
      _editingMedication = record;
      _medicationName.text = record.medicationName;
      _medicationType.text = record.medicationType;
      _dosageTaken.text = record.dosage;
      _frequency = record.frequency;
      _note.text = record.note ?? '';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Medication Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _medicationName,
                        decoration: const InputDecoration(
                          labelText: 'Medication Name',
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _medicationType,
                              decoration: const InputDecoration(
                                labelText: 'Medication Type',
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _dosageTaken,
                              decoration: const InputDecoration(
                                labelText: 'Dosage',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _frequency.toString(),
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('Once Daily'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Twice Daily'),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('Three times Daily'),
                          ),
                          DropdownMenuItem(value: '7', child: Text('Weekly')),
                          DropdownMenuItem(value: '30', child: Text('Monthly')),
                          DropdownMenuItem(value: '100', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          setState(() => _frequency = int.parse(val!));
                        },
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _note,
                        maxLines: null,
                        decoration: const InputDecoration(labelText: 'Note'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      final updatedRecord = _editingMedication!.copyWith(
                        medicationName: _medicationName.text,
                        medicationType: _medicationType.text,
                        dosage: _dosageTaken.text,
                        frequency: _frequency,
                        note: _note.text,
                      );
                      try {
                        await ref
                            .read(medicationProvider.notifier)
                            .updateMedicationEntry(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openEditMedicationIntakeModal(
    LocalMedicationIntake record,
    List<LocalMedication> medications,
  ) {
    setState(() {
      _editingMedicationIntake = record;
      _dosageTakenIntake.text = record.dosageTaken;
      session = record.session;
      _noteIntake.text = record.note ?? '';
      _dateIntake.text = record.intakeDate;
      _timeIntake.text = record.intakeTime;
      _medicationIndex = record.medicationId;
      final med = medications.firstWhere(
        (m) => m.id == record.medicationId,
        orElse: () => medications.first,
      );
      _medicationNameIntake.text =
          '${med.medicationName} | ${med.medicationType} | ${med.dosage}';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Medication Intake Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editIntakeFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TypeAheadField(
                        controller: _medicationNameIntake,
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(
                              suggestion.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                          List<String> parts = suggestion.toString().split(
                            ' | ',
                          );
                          int idx = medications.indexWhere(
                            (med) =>
                                parts.length == 3 &&
                                med.medicationName == parts[0] &&
                                med.medicationType == parts[1] &&
                                med.dosage == parts[2],
                          );
                          if (idx != -1 && medications[idx].id != null) {
                            _medicationIndex = medications[idx].id!;
                          }
                        },
                        suggestionsCallback: (pattern) async {
                          return medications
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                            child: DropdownButtonFormField<String>(
                              value: session,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Morning',
                                  child: Text('Morning'),
                                ),
                                DropdownMenuItem(
                                  value: 'Noon',
                                  child: Text('Noon'),
                                ),
                                DropdownMenuItem(
                                  value: 'Evening',
                                  child: Text('Evening'),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('Other'),
                                ),
                              ],
                              onChanged: (val) {
                                setDialogState(() {
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
                              readOnly: true,
                              onTap: () =>
                                  Datepicker.selectDate(context, _dateIntake),
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
                              readOnly: true,
                              onTap: () =>
                                  Datepicker.selectTime(context, _timeIntake),
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
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editIntakeFormKey.currentState!.validate()) {
                      final updatedRecord = _editingMedicationIntake!.copyWith(
                        medicationId: _medicationIndex,
                        dosageTaken: _dosageTakenIntake.text,
                        session: session,
                        note: _noteIntake.text,
                        intakeDate: _dateIntake.text,
                        intakeTime: _timeIntake.text,
                      );
                      try {
                        await ref
                            .read(medicationIntakeProvider.notifier)
                            .updateMedicationIntakeEntry(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _medicationName.clear();
    _dosageTaken.clear();
    _note.clear();
    _medicationType.clear();
    _medicationNameIntake.clear();
    _dosageTakenIntake.clear();
    _dateIntake.clear();
    _timeIntake.clear();
    _noteIntake.clear();
    setState(() {
      _editingMedication = null;
      _editingMedicationIntake = null;
      _frequency = 1;
      session = 'Other';
    });
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
            labelColor: Colors.green[700],
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.green[700],
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
    final medications = ref.watch(medicationProvider);
    final intakeRecords = ref.watch(medicationIntakeProvider);
    //var items;
    return SingleChildScrollView(
      child: Padding(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                  int idx = medications.indexWhere(
                    (med) =>
                        parts.length == 3 &&
                        med.medicationName == parts[0] &&
                        med.medicationType == parts[1] &&
                        med.dosage == parts[2],
                  );
                  if (idx != -1 && medications[idx].id != null) {
                    _medicationIndex = medications[idx].id!;
                  }
                },
                suggestionsCallback: (pattern) async {
                  return medications
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      controller: _timeIntake,
                      onTap: () => Datepicker.selectTime(context, _timeIntake),
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_formKeyIntake.currentState!.validate()) {
                        LocalMedicationIntake entry = LocalMedicationIntake(
                          userid: user!.id!,
                          medicationId: _medicationIndex,
                          dosageTaken: _dosageTakenIntake.text,
                          session: session,
                          note: _noteIntake.text,
                          intakeDate: _dateIntake.text.isNotEmpty
                              ? _dateIntake.text
                              : DateTime.now().toIso8601String().split('T')[0],
                          intakeTime: _timeIntake.text.isNotEmpty
                              ? _timeIntake.text
                              : '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
                        );
                        await ref
                            .read(medicationIntakeProvider.notifier)
                            .addMedicationIntakeEntry(entry);
                        showErrorSnackBar(
                          context,
                          'Medication Intake Entry Added Successfully',
                          Icons.check_circle,
                          Colors.green,
                        );
                        _medicationNameIntake.clear();
                        _medicationIndex = 0;
                        _dosageTakenIntake.clear();
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
                    backgroundColor: Colors.green[700],
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
              SizedBox(height: 20),
              Divider(color: Colors.black, thickness: 1),
              Center(
                child: Text(
                  'History of Medication Intake',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(color: Colors.black, thickness: 1),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.of(context).size.height * 0.3,
                child: intakeRecords.isEmpty
                    ? _isLoadingIntake
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No medication intake records found.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: intakeRecords.length,
                        itemBuilder: (context, index) {
                          final record = intakeRecords[index];
                          final med = medications.firstWhere(
                            (m) => m.id == record.medicationId,
                            orElse: () => LocalMedication(
                              userid: user!.id!,
                              medicationName: 'Unknown',
                              medicationType: 'Unknown',
                              dosage: 'Unknown',
                              frequency: 1,
                            ),
                          );
                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              trailing: SizedBox(
                                width: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () =>
                                            _openEditMedicationIntakeModal(
                                              record,
                                              medications,
                                            ),
                                        icon: Icon(
                                          Icons.edit,
                                          size: 25,
                                          color: Colors.green[700],
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () => {
                                          _deleteMedicationIntakeEntry(
                                            record.id!,
                                            user!.id!,
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
                              title: Text(
                                'Medication: ${med.medicationName}\nDosage Taken: ${record.dosageTaken}\nSession: ${record.session}',
                              ),
                              subtitle: Text(
                                'Note: ${record.note}\nDate: ${record.intakeDate} Time: ${record.intakeTime}',
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
    );
  }

  Widget _newMedicationTab() {
    final user = ref.watch(authProvider);
    final records = ref.watch(medicationProvider);
    return SingleChildScrollView(
      child: Padding(
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                  DropdownMenuItem(
                    value: '3',
                    child: Text('Three times Daily'),
                  ),
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
                        LocalMedication entry = LocalMedication(
                          userid: user!.id!,
                          medicationName: _medicationName.text,
                          medicationType: _medicationType.text,
                          dosage: _dosageTaken.text,
                          frequency: _frequency,
                          note: _note.text,
                          active: true,
                        );
                        await ref
                            .read(medicationProvider.notifier)
                            .addMedicationEntry(entry);
                        showErrorSnackBar(
                          context,
                          'Medication Entry Added Successfully',
                          Icons.check_circle,
                          Colors.green,
                        );
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
                    backgroundColor: Colors.green[700],
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
                                width: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () =>
                                            _openEditMedicationModal(record),
                                        icon: Icon(
                                          Icons.edit,
                                          size: 25,
                                          color: Colors.green[700],
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () => {
                                          _deleteMedicationEntry(
                                            record.id!,
                                            user!.id!,
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
        await ref.read(exerciseProvider.notifier).getExerciseEntries(user.id!);
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

  Future<void> _deleteExerciseEntry(int entryId, int userId) async {
    try {
      await ref
          .read(exerciseProvider.notifier)
          .deleteExerciseEntry(entryId, userId);
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
                              LocalPhysicalActivity
                              entry = LocalPhysicalActivity(
                                userid: user!.id!,
                                exerciseType: _exerciseTypeController.text,
                                durationMinutes: int.parse(
                                  _durationController.text,
                                ),
                                intensity: _intensity ?? 'Moderate',
                                note: _noteController.text,
                                exerciseDate: _dateController.text.isNotEmpty
                                    ? _dateController.text
                                    : DateTime.now().toIso8601String().split(
                                        'T',
                                      )[0],
                                exerciseTime: _timeController.text.isNotEmpty
                                    ? _timeController.text
                                    : '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
                              );
                              await ref
                                  .read(exerciseProvider.notifier)
                                  .addExerciseEntry(entry);
                              showErrorSnackBar(
                                context,
                                'Exercise Entry Added Successfully',
                                Icons.check_circle,
                                Colors.green,
                              );
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
                          backgroundColor: Colors.green[700],
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
                                          color: Colors.green[700],
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
                                            user!.id!,
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
                              '${record.exerciseType} - ${record.durationMinutes} mins - Intensity: ${record.intensity}'
                              '\nNote: ${record.note}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${record.exerciseDate}       Time: ${record.exerciseTime}',
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
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _mealTypeController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  LocalFoodIntake? _editingRecord;

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

  Future<void> _deleteFoodEntry(int entryId, int userId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ref.read(foodProvider.notifier).deleteFoodEntry(entryId, userId);
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
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadFoodEntries() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = ref.read(authProvider);
      if (user != null) {
        await ref.read(foodProvider.notifier).getFoodEntries(user.id!);
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

  void _openEditModal(LocalFoodIntake record) {
    setState(() {
      _editingRecord = record;
      _foodController.text = record.foodDescription;
      _noteController.text = record.note ?? '';
      _dateController.text = record.intakeDate;
      _timeController.text = record.intakeTime ?? '';
      _quantityController.text = record.quantity?.toString() ?? '';
      _caloriesController.text = record.calories?.toString() ?? '';
      _mealTypeController.text = record.mealType ?? '';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Food Intake Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Calories',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _mealTypeController,
                        decoration: InputDecoration(
                          labelText: 'Meal Type',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _noteController,
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
                              readOnly: true,
                              onTap: () => Datepicker.selectDate(
                                context,
                                _dateController,
                              ),
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
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      final updatedRecord = _editingRecord!.copyWith(
                        foodDescription: _foodController.text,
                        note: _noteController.text,
                        intakeDate: _dateController.text,
                        intakeTime: _timeController.text,
                        quantity: _quantityController.text.isNotEmpty
                            ? int.tryParse(_quantityController.text)
                            : null,
                        calories: _caloriesController.text.isNotEmpty
                            ? int.tryParse(_caloriesController.text)
                            : null,
                        mealType: _mealTypeController.text.isNotEmpty
                            ? _mealTypeController.text
                            : null,
                        syncStatus: 0, // mark as unsynced on edit
                      );
                      try {
                        await ref
                            .read(foodProvider.notifier)
                            .updateFoodEntry(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _foodController.clear();
    _noteController.clear();
    _dateController.clear();
    _timeController.clear();
    _quantityController.clear();
    _caloriesController.clear();
    _mealTypeController.clear();
    setState(() {
      _editingRecord = null;
    });
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
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Calories',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _mealTypeController,
                        decoration: InputDecoration(
                          labelText: 'Meal Type',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _noteController,
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
                                LocalFoodIntake entry = LocalFoodIntake(
                                  userid: user!.id!,
                                  foodDescription: _foodController.text,
                                  quantity: _quantityController.text.isNotEmpty
                                      ? int.tryParse(_quantityController.text)
                                      : null,
                                  calories: _caloriesController.text.isNotEmpty
                                      ? int.tryParse(_caloriesController.text)
                                      : null,
                                  mealType: _mealTypeController.text.isNotEmpty
                                      ? _mealTypeController.text
                                      : null,
                                  intakeDate: _dateController.text.isNotEmpty
                                      ? _dateController.text
                                      : DateTime.now().toIso8601String().split(
                                          'T',
                                        )[0],
                                  intakeTime: _timeController.text,
                                  note: _noteController.text,
                                  syncStatus: 0,
                                );
                                await ref
                                    .read(foodProvider.notifier)
                                    .addFoodEntry(entry);
                                showErrorSnackBar(
                                  context,
                                  'Food Intake Entry added Successfully',
                                  Icons.check_circle,
                                  Colors.green,
                                );
                                _foodController.clear();
                                _noteController.clear();
                                _dateController.clear();
                                _timeController.clear();
                                _quantityController.clear();
                                _caloriesController.clear();
                                _mealTypeController.clear();
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
                            backgroundColor: Colors.green[700],
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
                                                onPressed: () =>
                                                    _openEditModal(record),
                                                icon: Icon(
                                                  Icons.edit,
                                                  size: 25,
                                                  color: Colors.green[700],
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Expanded(
                                              child: IconButton(
                                                onPressed: () => {
                                                  _deleteFoodEntry(
                                                    record.id!,
                                                    user!.id!,
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
                                      title: Text(
                                        'Food: ${record.foodDescription} '
                                        '\nNote: ${record.note}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Date: ${record.intakeDate} '
                                        'Time: ${record.intakeTime}',
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

class BodyMeasurementEntry extends ConsumerStatefulWidget {
  const BodyMeasurementEntry({super.key});

  @override
  ConsumerState<BodyMeasurementEntry> createState() =>
      _BodyMeasurementEntryState();
}

class _BodyMeasurementEntryState extends ConsumerState<BodyMeasurementEntry> {
  int _selectedIndex = 6;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  double? _calculatedBMI;
  LocalBodyMeasurement? _editingRecord;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBodyMeasurements();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  Future<void> _deleteBodyMeasurement(int entryId, int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ref
            .read(bodyMeasurementProvider.notifier)
            .deleteBodyMeasurement(entryId, userId);
        showErrorSnackBar(
          context,
          'Body Measurement Entry Deleted Successfully',
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
  }

  void _openEditModal(LocalBodyMeasurement record) {
    setState(() {
      _editingRecord = record;
      _heightController.text = record.heightCm.toString();
      _weightController.text = record.weightKg.toString();
      _noteController.text = record.note ?? '';
      _dateController.text = record.measurementDate ?? '';
      _timeController.text = record.measurementTime ?? '';
      _calculateBMI();
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Body Measurement Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => _calculateBMI(),
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Height is required';
                                if (double.tryParse(value) == null)
                                  return 'Height must be valid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => _calculateBMI(),
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Weight is required';
                                if (double.tryParse(value) == null)
                                  return 'Weight must be valid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_calculatedBMI != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            color: _getBMIColor(_calculatedBMI!),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'BMI: ${_calculatedBMI!.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getBMICategory(_calculatedBMI!),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Note'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _timeController,
                              decoration: const InputDecoration(
                                labelText: 'Time',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      if (_calculatedBMI == null) {
                        _calculateBMI();
                      }
                      final updatedRecord = _editingRecord!.copyWith(
                        heightCm: double.parse(_heightController.text),
                        weightKg: double.parse(_weightController.text),
                        bmi: _calculatedBMI!,
                        note: _noteController.text,
                        measurementDate: _dateController.text,
                        measurementTime: _timeController.text,
                        syncStatus: 0, // mark as unsynced after edit
                      );
                      try {
                        await ref
                            .read(bodyMeasurementProvider.notifier)
                            .updateBodyMeasurement(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _heightController.clear();
    _weightController.clear();
    _noteController.clear();
    _dateController.clear();
    _timeController.clear();
    setState(() {
      _editingRecord = null;
      _calculatedBMI = null;
    });
  }

  Future<void> _loadBodyMeasurements() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(bodyMeasurementProvider.notifier)
            .getBodyMeasurements(user.id!);
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

  void _calculateBMI() {
    final heightText = _heightController.text;
    final weightText = _weightController.text;

    if (heightText.isNotEmpty && weightText.isNotEmpty) {
      final height = double.tryParse(heightText);
      final weight = double.tryParse(weightText);

      if (height != null && weight != null && height > 0 && weight > 0) {
        setState(() {
          _calculatedBMI = LocalBodyMeasurement.calculateBMI(height, weight);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final measurements = ref.watch(bodyMeasurementProvider);
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    TimeOfDay currentTime = TimeOfDay.now();
    _timeController.text = currentTime.format(context);

    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHistory(nameOfPage: 'Body Measurements', userData: {}),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Height (cm)',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onChanged: (_) => _calculateBMI(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Height is required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Height must be a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Weight (kg)',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onChanged: (_) => _calculateBMI(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Weight is required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Weight must be a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_calculatedBMI != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Card(
                            color: _getBMIColor(_calculatedBMI!),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'BMI: ${_calculatedBMI!.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _getBMICategory(_calculatedBMI!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          if (_formKey.currentState!.validate()) {
                            if (_calculatedBMI == null) {
                              _calculateBMI();
                            }

                            int userId = user!.id!;

                            LocalBodyMeasurement
                            measurement = LocalBodyMeasurement(
                              userid: userId,
                              heightCm: double.parse(_heightController.text),
                              weightKg: double.parse(_weightController.text),
                              bmi: _calculatedBMI!,
                              measurementDate: _dateController.text.isNotEmpty
                                  ? _dateController.text
                                  : DateTime.now().toIso8601String().split(
                                      'T',
                                    )[0],
                              measurementTime: _timeController.text.isNotEmpty
                                  ? _timeController.text
                                  : '${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}',
                              note: _noteController.text,
                              syncStatus: 0,
                            );

                            try {
                              setState(() => _isLoading = true);
                              await ref
                                  .read(bodyMeasurementProvider.notifier)
                                  .addBodyMeasurement(measurement);
                              showErrorSnackBar(
                                context,
                                'Body Measurement Entry Added Successfully',
                                Icons.check_circle,
                                Colors.green,
                              );

                              _heightController.clear();
                              _weightController.clear();
                              _noteController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              setState(() {
                                _calculatedBMI = null;
                              });
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
                          backgroundColor: Colors.green[700],
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
                        'History of Body Measurements',
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
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: measurements.isEmpty
                          ? _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'No body measurement records found.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: measurements.length,
                              itemBuilder: (context, index) {
                                final record = measurements[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  child: ListTile(
                                    trailing: SizedBox(
                                      width: 60,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _openEditModal(record),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 25,
                                                color: Colors.green[700],
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _deleteBodyMeasurement(
                                                    record.id!,
                                                    record.userid,
                                                  ),
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
                                      'Height: ${record.heightCm} cm, Weight: ${record.weightKg} kg\nBMI: ${record.bmi.toStringAsFixed(1)} (${_getBMICategory(record.bmi)})',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Date: ${record.measurementDate}  Time: ${record.measurementTime}',
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

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class SymptomsEntry extends ConsumerStatefulWidget {
  const SymptomsEntry({super.key});

  @override
  ConsumerState<SymptomsEntry> createState() => _SymptomsEntryState();
}

class _SymptomsEntryState extends ConsumerState<SymptomsEntry> {
  int _selectedIndex = 7;
  final TextEditingController _symptomNameController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  LocalSymptom? _editingRecord;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSymptomsData();
    });
  }

  Future<void> _loadSymptomsData() async {
    final user = ref.read(authProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await ref.read(symptomProvider.notifier).getSymptomEntries(user.id!);
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

  Future<void> _deleteSymptomEntry(int entryId, int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ref
            .read(symptomProvider.notifier)
            .deleteSymptomEntry(entryId, userId);
        showErrorSnackBar(
          context,
          'Symptom Entry Deleted Successfully',
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
  }

  void _openEditModal(LocalSymptom record) {
    setState(() {
      _editingRecord = record;
      _symptomNameController.text = record.symptomName;
      _severityController.text = record.severity?.toString() ?? '';
      _noteController.text = record.note ?? '';
      _dateController.text = record.recordedDate ?? '';
      _timeController.text = record.recordedTime ?? '';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Symptom Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _symptomNameController,
                        decoration: const InputDecoration(labelText: 'Symptom'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Symptom must not be empty';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _severityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Severity (1-5)',
                        ),
                      ),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Note'),
                      ),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () =>
                            Datepicker.selectDate(context, _dateController),
                        decoration: const InputDecoration(labelText: 'Date'),
                      ),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: () =>
                            Datepicker.selectTime(context, _timeController),
                        decoration: const InputDecoration(labelText: 'Time'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearControllers();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      final updatedRecord = _editingRecord!.copyWith(
                        symptomName: _symptomNameController.text,
                        severity: _severityController.text.isNotEmpty
                            ? int.tryParse(_severityController.text)
                            : null,
                        note: _noteController.text,
                        recordedDate: _dateController.text,
                        recordedTime: _timeController.text,
                      );

                      try {
                        await ref
                            .read(symptomProvider.notifier)
                            .updateSymptomEntry(updatedRecord);
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Entry updated successfully!',
                            Icons.check_circle,
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                          _clearControllers();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Failed to update entry: $e',
                            Icons.error,
                            Colors.red,
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _symptomNameController.clear();
    _severityController.clear();
    _noteController.clear();
    _dateController.clear();
    _timeController.clear();
    setState(() {
      _editingRecord = null;
    });
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
    final records = ref.watch(symptomProvider);
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    TimeOfDay currentTime = TimeOfDay.now();
    _timeController.text = currentTime.format(context);
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHistory(nameOfPage: 'Symptoms', userData: {}),
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
                    TextFormField(
                      controller: _symptomNameController,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Symptom',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Symptom must not be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _severityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Severity (1-5)',
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
                          if (_formKey.currentState!.validate()) {
                            int userId = user!.id!;

                            LocalSymptom entry = LocalSymptom(
                              userid: userId,
                              symptomName: _symptomNameController.text,
                              severity: _severityController.text.isNotEmpty
                                  ? int.tryParse(_severityController.text)
                                  : null,
                              note: _noteController.text,
                              recordedDate: _dateController.text.isNotEmpty
                                  ? _dateController.text
                                  : DateTime.now()
                                        .toIso8601String()
                                        .split('T')
                                        .first,
                              recordedTime: _timeController.text,
                            );
                            try {
                              setState(() => _isLoading = true);
                              await ref
                                  .read(symptomProvider.notifier)
                                  .addSymptomEntry(entry);
                              showErrorSnackBar(
                                context,
                                'Symptom Entry Added Successfully',
                                Icons.check_circle,
                                Colors.green,
                              );

                              _symptomNameController.clear();
                              _severityController.clear();
                              _noteController.clear();
                              _dateController.clear();
                              _timeController.clear();
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
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Icon(Icons.save, size: 32),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(color: Colors.black, thickness: 1),
                    Center(
                      child: Text(
                        'History of Symptoms',
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
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: records.isEmpty
                          ? _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'No symptom records found.',
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
                                      width: 60,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _openEditModal(record),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 25,
                                                color: Colors.green[700],
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () =>
                                                  _deleteSymptomEntry(
                                                    record.id!,
                                                    user!.id!,
                                                  ),
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
                                      'Symptom: ${record.symptomName}${record.severity != null ? ' (Severity: ${record.severity})' : ''}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Note: ${record.note ?? ''}\nDate: ${record.recordedDate} Time: ${record.recordedTime}',
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
