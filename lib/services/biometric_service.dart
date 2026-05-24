import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'database_service.dart';

class BiometricService {
  BiometricService._privateConstructor();
  static final BiometricService instance = BiometricService._privateConstructor();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware and if there are registered biometrics.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      
      if (!canAuthenticate) return false;

      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking biometric availability: $e');
      }
      return false;
    }
  }

  /// Triggers the native biometric authentication prompt.
  Future<bool> authenticate(String reason) async {
    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      return authenticated;
    } catch (e) {
      if (kDebugMode) {
        print('Error during biometric authentication: $e');
      }
      return false;
    }
  }

  /// Checks if the user has enabled biometric lock in settings.
  Future<bool> isBiometricEnabled() async {
    try {
      final val = await DatabaseService.instance.fetchSessionValue('biometric_enabled');
      return val == '1';
    } catch (e) {
      if (kDebugMode) {
        print('Error reading biometric_enabled from DB: $e');
      }
      return false;
    }
  }

  /// Saves the user's preference for biometric lock.
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await DatabaseService.instance.saveSessionValue(
        'biometric_enabled',
        enabled ? '1' : '0',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error writing biometric_enabled to DB: $e');
      }
    }
  }
}
