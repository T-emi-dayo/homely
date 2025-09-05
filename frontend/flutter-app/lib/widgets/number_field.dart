import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final void Function(int) onChanged;
  final int? initialValue;
  final int min;
  final int max;

  const NumberField({
    super.key,
    required this.label,
    this.hint,
    required this.onChanged,
    this.initialValue,
    this.min = 0,
    this.max = 1000,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: (initialValue ?? '').toString(),
    );
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        final val = int.tryParse(v);
        if (val == null) return 'Enter a valid number';
        if (val < min) return 'Must be ≥ $min';
        if (val > max) return 'Must be ≤ $max';
        return null;
      },
      onChanged: (v) {
        final val = int.tryParse(v) ?? min;
        onChanged(val);
      },
    );
  }
}
