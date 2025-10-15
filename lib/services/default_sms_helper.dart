import 'dart:io';
import 'package:flutter/services.dart';

class DefaultSmsHelper {
  static const _channel = MethodChannel('default_sms');

  /// Requests the user to set this app as the default SMS app
  static Future<bool> requestDefaultSmsApp() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('requestDefaultSmsApp');
      return result == true;
    } on PlatformException catch (e) {
      print("Failed to request default SMS: ${e.message}");
      return false;
    }
  }
}
