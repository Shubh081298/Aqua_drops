import 'package:flutter/material.dart';

/// Central color palette — Water Level Monitor
/// Source: Architecture spec Section 10.2
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1769AA); // Deep Blue
  static const Color secondary      = Color(0xFF29B6F6); // Water Blue
  static const Color waterFill      = Color(0xFF64C7F2); // Light Blue

  // ── Background & Surface ───────────────────────────────────
  static const Color background     = Color(0xFFF5F8FC); // Soft White
  static const Color card           = Color(0xFFFFFFFF); // White
  static const Color cardElevated   = Color(0xFFF0F5FB);

  // ── Status ─────────────────────────────────────────────────
  static const Color success        = Color(0xFF219653); // Green
  static const Color warning        = Color(0xFFF2A900); // Amber
  static const Color critical       = Color(0xFFDC4545); // Red
  static const Color info           = Color(0xFF29B6F6); // Blue

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF172B4D); // Dark Navy
  static const Color textSecondary  = Color(0xFF718096); // Grey
  static const Color textOnPrimary  = Color(0xFFFFFFFF);
  static const Color textDisabled   = Color(0xFFB0BAC9);

  // ── Border & Divider ───────────────────────────────────────
  static const Color border         = Color(0xFFE3EAF2);
  static const Color divider        = Color(0xFFEEF2F7);

  // ── Water Level — fill colors per step ─────────────────────
  static const Color levelEmpty     = Color(0xFFE3EAF2); // grey
  static const Color levelLow       = Color(0xFFDC4545); // red
  static const Color levelHalf      = Color(0xFFF2A900); // amber
  static const Color levelGood      = Color(0xFF29B6F6); // water blue
  static const Color levelHigh      = Color(0xFF1769AA); // deep blue
  static const Color levelFull      = Color(0xFF219653); // green

  // ── Motor Status ───────────────────────────────────────────
  static const Color motorOn        = Color(0xFF219653);
  static const Color motorOff       = Color(0xFF718096);
  static const Color motorFault     = Color(0xFFDC4545);
  static const Color motorCooldown  = Color(0xFFF2A900);

  // ── Inlet ──────────────────────────────────────────────────
  static const Color inletFlowing   = Color(0xFF29B6F6);
  static const Color inletNoFlow    = Color(0xFFB0BAC9);

  // ── Overlay ────────────────────────────────────────────────
  static const Color scrim          = Color(0x80000000);

  /// Returns the appropriate level color for a given percentage (discrete).
  static Color forLevel(int percent) {
    return switch (percent) {
      0        => levelEmpty,
      <= 25    => levelLow,
      <= 50    => levelHalf,
      <= 75    => levelGood,
      <= 99    => levelHigh,
      _        => levelFull,
    };
  }
}
