import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardService {
  ClipboardService._();

  static const _phoneKey = 'user_phone_number';

  /// Save user's phone number
  static Future<void> savePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    // Normalize: remove spaces, dashes, and leading +62 → 0
    final normalized = _normalizePhone(phone);
    await prefs.setString(_phoneKey, normalized);
  }

  /// Get saved phone number
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Normalize phone number: strip non-digits, convert +62 to 0
  static String _normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  /// Check clipboard for the user's phone number.
  /// Returns the detected phone number if found, null otherwise.
  static Future<String?> checkForPhoneNumber() async {
    try {
      final savedPhone = await getPhoneNumber();
      if (savedPhone == null || savedPhone.isEmpty) return null;

      final data = await Clipboard.getData('text/plain');
      if (data == null || data.text == null || data.text!.isEmpty) return null;

      final clipText = data.text!.replaceAll(RegExp(r'[^\d]'), '');

      // Check if clipboard contains the user's phone number
      if (clipText.contains(savedPhone)) {
        return savedPhone;
      }

      // Also check with +62 format
      if (savedPhone.startsWith('0')) {
        final intlFormat = '62${savedPhone.substring(1)}';
        if (clipText.contains(intlFormat)) {
          return savedPhone;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Format phone for display: 0812-3456-7890
  static String formatPhone(String phone) {
    final normalized = _normalizePhone(phone);
    if (normalized.length < 10) return normalized;
    // Format: 0812-3456-7890
    final buffer = StringBuffer();
    buffer.write(normalized.substring(0, 4));
    buffer.write('-');
    buffer.write(normalized.substring(4, 8));
    buffer.write('-');
    buffer.write(normalized.substring(8));
    return buffer.toString();
  }
}
