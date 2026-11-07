/// Typed exceptions used throughout the app.
/// Never show raw Firebase or Dart exceptions to users.

sealed class AppException implements Exception {
  const AppException({required this.message, this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AppException[$code]: $message';
}

// ── Authentication ─────────────────────────────────────────────────────────────
class AuthException extends AppException {
  const AuthException({required super.message, super.code});

  factory AuthException.invalidCredentials() =>
      const AuthException(message: 'Invalid email or password.', code: 'invalid-credentials');

  factory AuthException.accountDisabled() =>
      const AuthException(message: 'This account has been disabled.', code: 'account-disabled');

  factory AuthException.sessionExpired() =>
      const AuthException(message: 'Your session has expired. Please log in again.', code: 'session-expired');

  factory AuthException.networkError() =>
      const AuthException(message: 'Network error. Please check your connection.', code: 'network-error');

  factory AuthException.unknown(String detail) =>
      AuthException(message: 'Sign-in failed: $detail', code: 'unknown');
}

// ── Permissions ────────────────────────────────────────────────────────────────
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});

  factory PermissionException.insufficientRole() =>
      const PermissionException(message: 'You do not have permission for this action.', code: 'insufficient-role');

  factory PermissionException.customerMismatch() =>
      const PermissionException(message: 'Access denied. This resource belongs to another customer.', code: 'customer-mismatch');
}

// ── Network ────────────────────────────────────────────────────────────────────
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});

  factory NetworkException.noConnection() =>
      const NetworkException(message: 'No internet connection.', code: 'no-connection');

  factory NetworkException.timeout() =>
      const NetworkException(message: 'Request timed out. Please try again.', code: 'timeout');
}

// ── Firestore / Data ───────────────────────────────────────────────────────────
class DataException extends AppException {
  const DataException({required super.message, super.code});

  factory DataException.notFound(String resource) =>
      DataException(message: '$resource not found.', code: 'not-found');

  factory DataException.invalidData(String field) =>
      DataException(message: 'Invalid data in field: $field.', code: 'invalid-data');

  factory DataException.writeFailed() =>
      const DataException(message: 'Failed to save data. Please try again.', code: 'write-failed');
}

// ── Device / Command ───────────────────────────────────────────────────────────
class CommandException extends AppException {
  const CommandException({required super.message, super.code});

  factory CommandException.deviceOffline() =>
      const CommandException(message: 'Device is offline. Command cannot be sent.', code: 'device-offline');

  factory CommandException.expired() =>
      const CommandException(message: 'Command expired before the device could respond.', code: 'command-expired');

  factory CommandException.rejectedBySafety() =>
      const CommandException(message: 'Command rejected by device safety logic.', code: 'safety-rejection');

  factory CommandException.motorFault() =>
      const CommandException(message: 'Motor reported a fault. Please check hardware.', code: 'motor-fault');

  factory CommandException.noPermission() =>
      const CommandException(message: 'You are not authorised to control this motor.', code: 'no-motor-permission');
}

// ── Validation ─────────────────────────────────────────────────────────────────
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});

  factory ValidationException.thresholdConflict() =>
      const ValidationException(
        message: 'Minimum level must be lower than maximum level.',
        code: 'threshold-conflict',
      );

  factory ValidationException.requiredField(String field) =>
      ValidationException(message: '$field is required.', code: 'required-field');

  factory ValidationException.invalidEmail() =>
      const ValidationException(message: 'Please enter a valid email address.', code: 'invalid-email');
}
