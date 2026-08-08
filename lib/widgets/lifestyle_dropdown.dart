import 'package:flutter/material.dart';

class LifestyleDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  const LifestyleDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator ??
          (isRequired
              ? (selected) => selected == null || selected.isEmpty
                  ? 'Please select $label'
                  : null
              : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select $label',
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
