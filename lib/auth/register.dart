import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diacare/models/lifestyle_constants.dart';
import 'package:diacare/provider/authProvider.dart';
import 'package:diacare/widgets/components.dart';
import 'package:diacare/widgets/datePicker.dart';
import 'package:diacare/widgets/lifestyle_dropdown.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _diagnosisDateController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _sex;
  String? _smokingStatus;
  String? _alcoholConsumption;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A), Colors.white],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(),
            child: const Icon(
              Icons.health_and_safety,
              size: 80,
              color: Colors.white70,
            ),
          ),
          Positioned(
            top: 150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 210,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Register Now!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please Sign Up to start using DiaCare.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email (Username)',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please enter your email'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _functionController,
                        decoration: InputDecoration(
                          labelText: 'Occupation',
                          prefixIcon: const Icon(Icons.work_outline),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your occupation'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.home_outlined),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () =>
                            Datepicker.selectDate(context, _dateController),
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your date of birth'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _diagnosisDateController,
                        readOnly: true,
                        onTap: () => Datepicker.selectDate(
                          context,
                          _diagnosisDateController,
                        ),
                        decoration: InputDecoration(
                          labelText: 'First Diagnosis Date (Optional)',
                          prefixIcon: const Icon(
                            Icons.medical_services_outlined,
                          ),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      LifestyleDropdown(
                        label: 'Sex',
                        icon: Icons.wc_outlined,
                        options: LifestyleConstants.sexOptions,
                        value: _sex,
                        onChanged: (value) {
                          setState(() => _sex = value);
                        },
                      ),
                      const SizedBox(height: 15),
                      LifestyleDropdown(
                        label: 'Smoking Status',
                        icon: Icons.smoke_free_outlined,
                        options: LifestyleConstants.smokingStatusOptions,
                        value: _smokingStatus,
                        onChanged: (value) {
                          setState(() => _smokingStatus = value);
                        },
                      ),
                      const SizedBox(height: 15),
                      LifestyleDropdown(
                        label: 'Alcohol Consumption',
                        icon: Icons.local_bar_outlined,
                        options: LifestyleConstants.alcoholConsumptionOptions,
                        value: _alcoholConsumption,
                        onChanged: (value) {
                          setState(() => _alcoholConsumption = value);
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _rPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                            value == null ||
                                value.isEmpty ||
                                _passwordController.text !=
                                    _rPasswordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            showErrorSnackBar(
                              context,
                              'Please complete all required fields, including sex, smoking status, and alcohol consumption.',
                              Icons.warning_amber_rounded,
                              Colors.orange,
                            );
                            return;
                          }

                          final result = await ref
                              .read(authProvider.notifier)
                              .registerUser(
                                username: _emailController.text.trim(),
                                password: _passwordController.text,
                                nickname: _nameController.text.trim(),
                                function: _functionController.text.trim(),
                                address: _addressController.text.trim(),
                                dob: _dateController.text,
                                sex: _sex,
                                firstDiagnosisDate:
                                    _diagnosisDateController.text.isEmpty
                                    ? null
                                    : _diagnosisDateController.text,
                                smokingStatus: _smokingStatus,
                                alcoholConsumption: _alcoholConsumption,
                              );

                          if (!mounted) return;

                          if (result['success'] == true) {
                            showErrorSnackBar(
                              context,
                              'You are registered successfully!',
                              Icons.check_circle,
                              Colors.green,
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              '/Dashboard',
                            );
                          } else {
                            showErrorSnackBar(
                              context,
                              result['error'] ?? 'Error registering user!',
                              Icons.error,
                              Colors.red,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/Login');
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
