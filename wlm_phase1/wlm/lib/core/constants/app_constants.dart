/// Central constants for the Water Level Monitor application.
/// Update values here only — never hardcode strings elsewhere.
abstract final class AppConstants {

  // ── App ────────────────────────────────────────────────────
  static const String appName    = 'Water Level Monitor';
  static const String appVersion = '1.0.0';

  // ── Firestore collections ──────────────────────────────────
  static const String colUsers          = 'users';
  static const String colCustomers      = 'customers';
  static const String colMembers        = 'members';    // sub of customers
  static const String colDevices        = 'devices';
  static const String colHistory        = 'history';    // sub of devices
  static const String colMotorLogs      = 'motorLogs';  // sub of devices
  static const String colAlerts         = 'alerts';     // sub of devices
  static const String colCommands       = 'commands';   // sub of devices
  static const String colNotifications  = 'notifications';
  static const String colAuditLogs      = 'auditLogs';
  static const String colDeviceRegistry = 'deviceRegistry';

  // ── Role values (Firestore strings) ───────────────────────
  static const String roleSuperAdmin    = 'super_admin';
  static const String roleCustomerAdmin = 'customer_admin';
  static const String roleCustomerUser  = 'customer_user';

  // ── User / device status ───────────────────────────────────
  static const String statusActive   = 'active';
  static const String statusInactive = 'inactive';
  static const String statusDisabled = 'disabled';

  // ── Level validity ─────────────────────────────────────────
  static const String levelValid    = 'valid';
  static const String levelFault    = 'fault';
  static const String levelStale    = 'stale';
  static const String levelUnknown  = 'unknown';

  // ── Motor states ───────────────────────────────────────────
  static const String motorIdle         = 'idle';
  static const String motorStarting     = 'starting';
  static const String motorRequested    = 'requested';   // relay ON, awaiting CT confirmation
  static const String motorRunning      = 'running';     // CT confirmed current > threshold
  static const String motorStopping     = 'stopping';
  static const String motorCooldown     = 'cooldown';
  static const String motorFault        = 'fault';
  static const String motorUnknown      = 'unknown';

  // ── Motor modes ────────────────────────────────────────────
  static const String motorModeAuto     = 'auto';
  static const String motorModeManual   = 'manual';

  // ── Command types ──────────────────────────────────────────
  static const String cmdMotorOn        = 'motor_on';
  static const String cmdMotorOff       = 'motor_off';
  static const String cmdReturnToAuto   = 'return_to_auto';

  // ── Command status ─────────────────────────────────────────
  static const String cmdPending        = 'pending';
  static const String cmdValidated      = 'validated';
  static const String cmdSent           = 'sent';
  static const String cmdAcknowledged   = 'acknowledged';
  static const String cmdExecuting      = 'executing';
  static const String cmdSucceeded      = 'succeeded';
  static const String cmdFailed         = 'failed';
  static const String cmdExpired        = 'expired';
  static const String cmdCancelled      = 'cancelled';

  // ── Alert types ────────────────────────────────────────────
  static const String alertCriticalLow      = 'critical_low_water';
  static const String alertMotorAutoStart   = 'motor_auto_start';
  static const String alertTankFull         = 'tank_full';
  static const String alertDryRun          = 'dry_run_detected';
  static const String alertNodeOffline     = 'node_offline';
  static const String alertSensorFault     = 'sensor_fault';
  static const String alertMotorOverload   = 'motor_overload';
  static const String alertMotorLong       = 'motor_ran_too_long';

  // ── Alert status ───────────────────────────────────────────
  static const String alertActive       = 'active';
  static const String alertAcknowledged = 'acknowledged';
  static const String alertResolved     = 'resolved';
  static const String alertArchived     = 'archived';

  // ── Device / reporting defaults ────────────────────────────
  static const int    defaultMinLevel           = 25;   // %
  static const int    defaultMaxLevel           = 100;  // %
  static const bool   defaultMotorEnabled       = true;
  static const int    defaultInletTimeoutMin    = 5;    // minutes
  static const int    defaultCooldownMin        = 10;   // minutes
  static const int    reportingIntervalSec      = 60;   // seconds
  static const int    commandExpiryMin          = 2;    // minutes
  static const int    historyRetentionDays      = 30;
  static const int    staleThresholdMin         = 5;    // minutes

  // ── CT sensor (motor current) ──────────────────────────────
  static const double ctRunningThresholdAmps    = 0.5;  // above = motor confirmed running
  static const double ctOverloadThresholdAmps   = 10.0; // below = likely fault (adjust per motor HP)

  // ── Water level steps (discrete — float switch hardware) ──
  static const List<int> levelSteps = [0, 25, 50, 75, 100];

  // ── Supported language codes ───────────────────────────────
  static const List<String> supportedLanguages = ['en', 'mr', 'hi'];
}
