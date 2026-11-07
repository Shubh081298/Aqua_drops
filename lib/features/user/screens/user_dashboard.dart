import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../providers/user_device_provider.dart';
import '../widgets/tank_level_painter.dart';

const _primary  = Color(0xFF1769AA);
const _bg       = Color(0xFFF5F8FC);
const _textDark = Color(0xFF172B4D);
const _textGrey = Color(0xFF718096);
const _success  = Color(0xFF219653);
const _warning  = Color(0xFFF2A900);
const _critical = Color(0xFFDC4545);
const _border   = Color(0xFFE3EAF2);

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fillAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceAsync = ref.watch(userDeviceProvider);
    final userName    = ref.watch(userDisplayNameProvider) ?? 'User';

    return Scaffold(
      backgroundColor: _bg,
      body: deviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
        error:   (e, _) => _errorView(e.toString()),
        data:    (device) => device == null
            ? _noDeviceView(userName)
            : _dashboardView(device.deviceId, device.deviceName, userName),
      ),
    );
  }

  // ── No device assigned ────────────────────────────────────────────────────
  Widget _noDeviceView(String name) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar('My Tank', null, false),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.water_drop_outlined, size: 72, color: Color(0xFFB0BAC9)),
          const SizedBox(height: 16),
          const Text('No device assigned',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textDark)),
          const SizedBox(height: 8),
          const Text('Contact your administrator to assign a device.',
              style: TextStyle(color: _textGrey)),
        ]),
      ),
    );
  }

  // ── Main dashboard ────────────────────────────────────────────────────────
  Widget _dashboardView(String deviceId, String deviceName, String userName) {
    final statusAsync = ref.watch(deviceStatusProvider(deviceId));

    return statusAsync.when(
      loading: () => Scaffold(
        backgroundColor: _bg,
        appBar: _appBar(deviceName, null, false),
        body: const Center(child: CircularProgressIndicator(color: _primary)),
      ),
      error: (e, _) => _errorView(e.toString()),
      data: (status) {
        if (status == null) {
          return Scaffold(
            backgroundColor: _bg,
            appBar: _appBar(deviceName, 0, false),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.wifi_off, size: 48, color: Color(0xFFB0BAC9)),
                  SizedBox(height: 12),
                  Text('Waiting for first reading...',
                      style: TextStyle(fontSize: 16, color: Color(0xFF718096))),
                  SizedBox(height: 8),
                  Text('Hub will connect once powered on.',
                      style: TextStyle(fontSize: 13, color: Color(0xFFB0BAC9))),
                ]),
              ),
            ),
          );
        }
        final level       = status.waterLevelPercent;
        final isValid     = status.levelValidity == 'valid';
        final isOnline    = status.isOnline;
        final motorState  = status.motorState;
        final motorMode   = status.motorMode;
        final inletFlow   = status.inletFlowDetected;
        final alertCount  = status.activeAlertCount;
        final currentAmps = status.motorCurrentAmps;
        final confirmed   = status.motorConfirmedRunning;
        final lastSeen    = status.lastSeenAt;
        final isStale     = status.isStale;

        return Scaffold(
          backgroundColor: _bg,
          appBar: _appBar(deviceName, alertCount, isOnline),
          body: IndexedStack(
            index: _currentTab,
            children: [
              _homeTab(deviceId, level, isValid, isOnline, motorState,
                  motorMode, inletFlow, currentAmps, confirmed, lastSeen, isStale),
              _historyTab(),
              _alertsTab(deviceId),
              _settingsTab(deviceId),
            ],
          ),
          bottomNavigationBar: _bottomNav(alertCount),
        );
      },
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar(String title, int? alertCount, bool isOnline) {
    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(children: [
        const Icon(Icons.water_drop, size: 22, color: Colors.white),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isOnline ? _success : _textGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(isOnline ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 11, color: Colors.white)),
        ),
      ]),
      actions: [
        if (alertCount != null && alertCount > 0)
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => setState(() => _currentTab = 2),
            ),
            Positioned(
              right: 8, top: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: _critical, shape: BoxShape.circle),
                child: Text('$alertCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
              ),
            ),
          ]),
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  // ── Home Tab ──────────────────────────────────────────────────────────────
  Widget _homeTab(
    String deviceId, int level, bool isValid, bool isOnline,
    String motorState, String motorMode, bool inletFlow,
    double? currentAmps, bool confirmed, DateTime? lastSeen, bool isStale,
  ) {
    final levelColor = _levelColor(level);
    final levelLabel = _levelLabel(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Stale banner
        if (isStale)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _warning),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber, color: _warning, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(
                isOnline ? 'Data may be outdated' : 'Device offline — showing last known data',
                style: const TextStyle(color: Color(0xFFE65100), fontSize: 12),
              )),
            ]),
          ),

        // Water level card
        _card(child: Row(children: [
          // Tank visual
          AnimatedBuilder(
            animation: _fillAnim,
            builder: (ctx, _) => SizedBox(
              width: 110, height: 180,
              child: CustomPaint(
                painter: TankLevelPainter(
                  levelPercent: level,
                  isValid: isValid,
                  animValue: _fillAnim.value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Level info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isValid ? '$level%' : '—',
              style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: levelColor),
            ),
            Text(isValid ? levelLabel : 'No reading',
                style: TextStyle(fontSize: 16, color: levelColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            if (lastSeen != null) ...[
              const Text('Last updated', style: TextStyle(fontSize: 11, color: _textGrey)),
              Text(_formatTime(lastSeen), style: const TextStyle(fontSize: 12, color: _textDark)),
            ],
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.water_outlined, size: 14, color: _textGrey),
              const SizedBox(width: 4),
              Text(inletFlow ? 'Inlet flowing' : 'No inlet flow',
                  style: TextStyle(fontSize: 12,
                      color: inletFlow ? _success : _textGrey)),
            ]),
          ])),
        ])),

        const SizedBox(height: 14),

        // Motor control card
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Motor Control',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark)),
            _modeBadge(motorMode),
          ]),
          const SizedBox(height: 14),

          // Motor status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _motorStatusBg(motorState, confirmed),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(_motorIcon(motorState, confirmed),
                  color: _motorStatusColor(motorState, confirmed), size: 22),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_motorLabel(motorState, confirmed),
                    style: TextStyle(fontWeight: FontWeight.w600,
                        color: _motorStatusColor(motorState, confirmed))),
                if (currentAmps != null)
                  Text('${currentAmps.toStringAsFixed(1)} A',
                      style: const TextStyle(fontSize: 12, color: _textGrey)),
              ])),
            ]),
          ),

          const SizedBox(height: 14),

          // Manual control buttons (only shown in manual mode)
          if (motorMode == 'manual') ...[
            const Text('Manual Override',
                style: TextStyle(fontSize: 12, color: _textGrey)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _success),
                onPressed: () => _sendCommand(deviceId, 'motor_on'),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Start'),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _critical),
                onPressed: () => _sendCommand(deviceId, 'motor_off'),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stop'),
              )),
            ]),
          ] else
            Text('Auto mode — motor managed by level thresholds.',
                style: const TextStyle(fontSize: 12, color: _textGrey)),
        ])),

        const SizedBox(height: 14),

        // Quick stats row
        Row(children: [
          Expanded(child: _miniStat('Motor Mode', motorMode.toUpperCase(), Icons.settings_outlined, _primary)),
          const SizedBox(width: 10),
          Expanded(child: _miniStat('Alerts', '${alertCount(0)}', Icons.notifications_outlined, _critical)),
        ]),
      ]),
    );
  }

  // ── History Tab ───────────────────────────────────────────────────────────
  Widget _historyTab() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.history_outlined, size: 48, color: Color(0xFFCBD5E0)),
      SizedBox(height: 12),
      Text('History coming soon', style: TextStyle(fontSize: 16, color: _textGrey)),
    ]));
  }

  // ── Alerts Tab ────────────────────────────────────────────────────────────
  Widget _alertsTab(String deviceId) {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.notifications_none_outlined, size: 48, color: Color(0xFFCBD5E0)),
      SizedBox(height: 12),
      Text('Alerts coming soon', style: TextStyle(fontSize: 16, color: _textGrey)),
    ]));
  }

  // ── Settings Tab ──────────────────────────────────────────────────────────
  Widget _settingsTab(String deviceId) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark)),
        const SizedBox(height: 20),
        _card(child: Column(children: [
          ListTile(
            leading: const Icon(Icons.tune_outlined, color: _primary),
            title: const Text('Device Config'),
            subtitle: const Text('View level thresholds'),
            trailing: const Icon(Icons.chevron_right, color: _textGrey),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: _critical),
            title: const Text('Sign Out', style: TextStyle(color: _critical)),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ])),
      ]),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _bottomNav(int alertCount) {
    return NavigationBar(
      selectedIndex: _currentTab,
      onDestinationSelected: (i) => setState(() => _currentTab = i),
      backgroundColor: Colors.white,
      indicatorColor: _primary.withValues(alpha: 0.12),
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        const NavigationDestination(icon: Icon(Icons.history_outlined), label: 'History'),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: alertCount > 0,
            label: Text('$alertCount'),
            child: const Icon(Icons.notifications_outlined),
          ),
          label: 'Alerts',
        ),
        const NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _textGrey)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      ]),
    );
  }

  Widget _modeBadge(String mode) {
    final isAuto = mode == 'auto';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isAuto ? _success : _warning).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAuto ? _success : _warning),
      ),
      child: Text(isAuto ? 'Auto' : 'Manual',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: isAuto ? _success : _warning)),
    );
  }

  Widget _errorView(String msg) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 48, color: _critical),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: _critical), textAlign: TextAlign.center),
      ])),
    );
  }

  Color _levelColor(int pct) {
    if (pct <= 0)  return _textGrey;
    if (pct <= 25) return _critical;
    if (pct <= 50) return _warning;
    return _success;
  }

  String _levelLabel(int pct) {
    if (pct <= 0)  return 'Empty';
    if (pct <= 25) return 'Low';
    if (pct <= 50) return 'Half';
    if (pct <= 75) return 'Good';
    if (pct <= 99) return 'High';
    return 'Full';
  }

  Color _motorStatusColor(String state, bool confirmed) {
    if (state == 'on' && confirmed) return _success;
    if (state == 'on')              return _warning;
    if (state == 'off')             return _textGrey;
    return _textGrey;
  }

  Color _motorStatusBg(String state, bool confirmed) =>
      _motorStatusColor(state, confirmed).withValues(alpha: 0.08);

  IconData _motorIcon(String state, bool confirmed) {
    if (state == 'on' && confirmed) return Icons.check_circle_outline;
    if (state == 'on')              return Icons.hourglass_empty_outlined;
    return Icons.power_settings_new_outlined;
  }

  String _motorLabel(String state, bool confirmed) {
    if (state == 'on' && confirmed) return 'Motor Running';
    if (state == 'on')              return 'Motor Starting…';
    return 'Motor Off';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _sendCommand(String deviceId, String command) async {
    try {
      await sendMotorCommand(deviceId, command);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(command == 'motor_on' ? 'Motor start command sent.' : 'Motor stop command sent.'),
            backgroundColor: command == 'motor_on' ? _success : _critical,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _critical),
        );
      }
    }
  }

  int alertCount(int fallback) => fallback;
}
