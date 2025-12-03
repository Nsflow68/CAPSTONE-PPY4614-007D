import 'package:flutter/services.dart';

class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convert to uppercase
    String newText = newValue.text.toUpperCase();
    
    // Remove all invalid characters (keep only numbers and K)
    newText = newText.replaceAll(RegExp(r'[^0-9K]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String body;
    String verifier;

    if (newText.length == 1) {
      // If only one character, just show it (no hyphen yet)
      // Or we could show it as body? 
      // Standard behavior: 1 -> 1. 12 -> 1-2.
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else {
      verifier = newText.substring(newText.length - 1);
      body = newText.substring(0, newText.length - 1);
    }

    // Format body without dots, just hyphen
    String formatted = '$body-$verifier';

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
