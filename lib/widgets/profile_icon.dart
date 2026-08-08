import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lifestyle_constants.dart';
import '../provider/authProvider.dart';
import '../widgets/components.dart';
import '../widgets/datePicker.dart';
import '../widgets/lifestyle_dropdown.dart';

class ProfileIcon extends ConsumerWidget {
  final Color? iconColor;
  final IconData? iconData;
  const ProfileIcon({super.key, this.iconColor, this.iconData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(iconData ?? Icons.person, color: iconColor ?? Colors.white),
      onPressed: () => _showProfileModal(context, ref),
    );
  }

  void _showProfileModal(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider);
    if (user == null) return;

    // Controllers for edit form
    final TextEditingController nicknameController = TextEditingController(
      text: user.nickname,
    );
    final TextEditingController emailController = TextEditingController(
      text: user.username,
    );
    final TextEditingController functionController = TextEditingController(
      text: user.function,
    );
    final TextEditingController addressController = TextEditingController(
      text: user.address,
    );
    final TextEditingController dobController = TextEditingController(
      text: user.dob,
    );
    final TextEditingController diagnosisDateController = TextEditingController(
      text: user.firstDiagnosisDate,
    );
    String? smokingStatus = user.smokingStatus;
    String? alcoholConsumption = user.alcoholConsumption;
    String? sex = user.sex;

    bool isEditing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? "Edit Profile" : "Profile",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!isEditing) ...[
                      _buildProfileDetail("Nickname", user.nickname ?? "-"),
                      const SizedBox(height: 12),
                      _buildProfileDetail("Email", user.username),
                      const SizedBox(height: 12),
                      _buildProfileDetail("Occupation", user.function ?? "-"),
                      const SizedBox(height: 12),
                      _buildProfileDetail("Address", user.address ?? "-"),
                      const SizedBox(height: 12),
                      _buildProfileDetail(
                        "Date of Birth",
                        user.dob ?? "Not provided",
                      ),
                      const SizedBox(height: 12),
                      _buildProfileDetail(
                        "Sex",
                        user.sex ?? "Not provided",
                      ),
                      const SizedBox(height: 12),
                      _buildProfileDetail(
                        "First Diagnosis Date",
                        user.firstDiagnosisDate ?? "Not provided",
                      ),
                      const SizedBox(height: 12),
                      _buildProfileDetail(
                        "Smoking Status",
                        user.smokingStatus ?? "Not provided",
                      ),
                      const SizedBox(height: 12),
                      _buildProfileDetail(
                        "Alcohol Consumption",
                        user.alcoholConsumption ?? "Not provided",
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else ...[
                      Consumer(
                        builder: (context, ref, child) {
                          return Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: nicknameController,
                                  decoration: InputDecoration(
                                    labelText: "Nickname",
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    filled: true,
                                    fillColor: Colors.green[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: const Icon(Icons.email),
                                    filled: true,
                                    fillColor: Colors.green[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: functionController,
                                  decoration: InputDecoration(
                                    labelText: "Occupation",
                                    prefixIcon: const Icon(Icons.work_outline),
                                    filled: true,
                                    fillColor: Colors.green[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: addressController,
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                    prefixIcon: const Icon(Icons.home_outlined),
                                    filled: true,
                                    fillColor: Colors.green[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: dobController,
                                  readOnly: true,
                                  onTap: () => Datepicker.selectDate(
                                    modalContext,
                                    dobController,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Date of Birth",
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                    filled: true,
                                    fillColor: Colors.green[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: diagnosisDateController,
                                  readOnly: true,
                                  onTap: () => Datepicker.selectDate(
                                    modalContext,
                                    diagnosisDateController,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "First Diagnosis Date",
                                    prefixIcon: const Icon(
                                      Icons.medical_services_outlined,
                                    ),
                                    filled: true,
                                    fillColor: Colors.green[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                LifestyleDropdown(
                                  label: "Sex",
                                  icon: Icons.wc_outlined,
                                  options: LifestyleConstants.sexOptions,
                                  value: sex,
                                  onChanged: (value) {
                                    setState(() => sex = value);
                                  },
                                  isRequired: false,
                                ),
                                const SizedBox(height: 12),
                                LifestyleDropdown(
                                  label: "Smoking Status",
                                  icon: Icons.smoke_free_outlined,
                                  options:
                                      LifestyleConstants.smokingStatusOptions,
                                  value: smokingStatus,
                                  onChanged: (value) {
                                    setState(() => smokingStatus = value);
                                  },
                                  isRequired: false,
                                ),
                                const SizedBox(height: 12),
                                LifestyleDropdown(
                                  label: "Alcohol Consumption",
                                  icon: Icons.local_bar_outlined,
                                  options: LifestyleConstants
                                      .alcoholConsumptionOptions,
                                  value: alcoholConsumption,
                                  onChanged: (value) {
                                    setState(
                                      () => alcoholConsumption = value,
                                    );
                                  },
                                  isRequired: false,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isEditing = false;
                                            // Reset controllers to original values
                                            nicknameController.text =
                                                user.nickname ?? '';
                                            emailController.text =
                                                user.username;
                                            functionController.text =
                                                user.function ?? '';
                                            addressController.text =
                                                user.address ?? '';
                                            dobController.text = user.dob ?? '';
                                            diagnosisDateController.text =
                                                user.firstDiagnosisDate ?? '';
                                            smokingStatus = user.smokingStatus;
                                            alcoholConsumption =
                                                user.alcoholConsumption;
                                            sex = user.sex;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          minimumSize: const Size(
                                            double.infinity,
                                            56,
                                          ),
                                        ),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final updatedUser = user.copyWith(
                                            nickname: nicknameController.text,
                                            username: emailController.text,
                                            function: functionController.text,
                                            address: addressController.text,
                                            dob: dobController.text,
                                            firstDiagnosisDate:
                                                diagnosisDateController
                                                    .text
                                                    .isEmpty
                                                ? null
                                                : diagnosisDateController.text,
                                            smokingStatus: smokingStatus,
                                            alcoholConsumption:
                                                alcoholConsumption,
                                            sex: sex,
                                          );
                                          final result = await ref
                                              .read(authProvider.notifier)
                                              .updateUser(updatedUser);
                                          if (modalContext.mounted) {
                                            if (result["success"] == true) {
                                              showErrorSnackBar(
                                                modalContext,
                                                "Profile updated successfully!",
                                                Icons.check_circle,
                                                Colors.green,
                                              );
                                              Navigator.pop(modalContext);
                                            } else {
                                              showErrorSnackBar(
                                                modalContext,
                                                result["error"] ??
                                                    "Error updating profile",
                                                Icons.error,
                                                Colors.red,
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2E7D32,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          minimumSize: const Size(
                                            double.infinity,
                                            56,
                                          ),
                                        ),
                                        child: const Text(
                                          "Save Changes",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
