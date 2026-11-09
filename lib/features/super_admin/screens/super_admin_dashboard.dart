import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/repositories/auth_repository.dart';
import '../providers/super_admin_providers.dart';
import 'customers_screen.dart';

// ── Colours ────────────────────────────────────────────────────────────────────
const _primary   = Color(0xFF1769AA);
const _bg        = Color(0xFFF5F8FC);
const _cardBg    = Colors.white;
const _border    = Color(0xFFE3EAF2);
const _textDark  = Color(0xFF172B4D);
const _textGrey  = Color(0xFF718096);
const _success   = Color(0xFF219653);
const _warning   = Color(0xFFF2A900);
const _critical  = Color(0xFFDC4545);

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});
  @override
  ConsumerState<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard> {
  int _selectedIndex = 0;

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined,      label: 'Dashboard'),
    _NavItem(icon: Icons.people_outline,           label: 'Customers'),
    _NavItem(icon: Icons.devices_other_outlined,  label: 'Devices'),
    _NavItem(icon: Icons.person_outline,           label: 'Users'),
    _NavItem(icon: Icons.notifications_outlined,  label: 'Alerts'),
    _NavItem(icon: Icons.settings_outlined,        label: 'Settings'),
  ];

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final name   = ref.watch(userDisplayNameProvider) ?? 'Super Admin';
    final isWide = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(name, isWide),
      body: isWide
          ? Row(children: [_Sidebar(items: _navItems, selected: _selectedIndex, onSelect: (i) => setState(() => _selectedIndex = i), onLogout: _signOut), Expanded(child: _body())])
          : _body(),
      bottomNavigationBar: isWide ? null : _buildBottomNav(),
    );
  }

  AppBar _buildAppBar(String name, bool isWide) => AppBar(
    backgroundColor: _primary,
    foregroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: 16,
    title: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.water_drop, color: Color(0xFF1769AA), size: 20),
      ),
      const SizedBox(width: 8),
      const Text('Water Level Monitor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
        child: const Text('Super Admin', style: TextStyle(fontSize: 11, color: Colors.white70)),
      ),
    ]),
    actions: [
      if (isWide) Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Center(child: Text(name, style: const TextStyle(fontSize: 13, color: Colors.white70))),
      ),
      IconButton(icon: const Icon(Icons.logout, size: 20), tooltip: 'Sign out', onPressed: _signOut),
      const SizedBox(width: 4),
    ],
  );

  NavigationBar _buildBottomNav() => NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (i) => setState(() => _selectedIndex = i),
    backgroundColor: Colors.white,
    indicatorColor: _primary.withValues(alpha: 0.12),
    destinations: _navItems.map((n) => NavigationDestination(icon: Icon(n.icon), label: n.label)).toList(),
  );

  Widget _body() => switch (_selectedIndex) {
    0 => const _DashboardTab(),
    1 => const CustomersScreen(),
    5 => _SettingsTab(onSignOut: _signOut),
    _ => _ComingSoon(label: _navItems[_selectedIndex].label),
  };
}

// ── Sidebar ────────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.items, required this.selected, required this.onSelect, required this.onLogout});
  final List<_NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      color: Colors.white,
      child: Column(children: [
        const SizedBox(height: 12),
        ...items.asMap().entries.map((e) => _SidebarTile(item: e.value, selected: selected == e.key, onTap: () => onSelect(e.key))),
        const Spacer(),
        const Divider(height: 1),
        _SidebarTile(
          item: const _NavItem(icon: Icons.logout, label: 'Logout'),
          selected: false,
          onTap: onLogout,
          danger: true,
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.selected, required this.onTap, this.danger = false});
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? _critical : selected ? _primary : _textGrey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? _primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Icon(item.icon, size: 19, color: color),
              const SizedBox(width: 10),
              Text(item.label, style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: color)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Tab ──────────────────────────────────────────────────────────────
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers     = ref.watch(totalCustomersProvider);
    final devices       = ref.watch(totalDevicesProvider);
    final online        = ref.watch(onlineDevicesProvider);
    final alerts        = ref.watch(activeAlertsProvider);
    final recentCustomers = ref.watch(recentCustomersProvider);

    final totalDev   = devices.valueOrNull ?? 0;
    final onlineDev  = online.valueOrNull ?? 0;
    final offlineDev = totalDev - onlineDev;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Stat cards ──
        LayoutBuilder(builder: (ctx, bc) {
          final cols = bc.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _StatCard(label: 'Total Customers', icon: Icons.people_outline,          color: _primary,  value: customers),
              _StatCard(label: 'Total Devices',   icon: Icons.devices_other_outlined,  color: _primary,  value: devices),
              _StatCard(label: 'Online Devices',  icon: Icons.wifi,                    color: _success,  value: online),
              _StatCard(label: 'Active Alerts',   icon: Icons.notifications_active_outlined, color: _critical, value: alerts),
            ],
          );
        }),

        const SizedBox(height: 20),

        // ── Charts row ──
        LayoutBuilder(builder: (ctx, bc) {
          final twoCol = bc.maxWidth > 640;
          if (twoCol) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _SystemOverviewCard(online: onlineDev, offline: offlineDev)),
              const SizedBox(width: 12),
              Expanded(child: const _ActivityChartCard()),
            ]);
          }
          return Column(children: [
            _SystemOverviewCard(online: onlineDev, offline: offlineDev),
            const SizedBox(height: 12),
            const _ActivityChartCard(),
          ]);
        }),

        const SizedBox(height: 20),

        // ── Customer table ──
        const Text('Customer Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
        const SizedBox(height: 10),
        _CustomerTable(stream: recentCustomers),
      ]),
    );
  }
}

// ── System Overview donut ──────────────────────────────────────────────────────
class _SystemOverviewCard extends StatelessWidget {
  const _SystemOverviewCard({required this.online, required this.offline});
  final int online;
  final int offline;

  @override
  Widget build(BuildContext context) {
    final total = online + offline;
    final pct   = total == 0 ? 0 : (online / total * 100).round();

    return _Card(
      title: 'System Overview',
      child: SizedBox(
        height: 200,
        child: total == 0
            ? const Center(child: Text('No devices yet', style: TextStyle(color: _textGrey)))
            : Row(children: [
                // Donut chart — fixed 160px
                SizedBox(
                  width: 160, height: 160,
                  child: Stack(alignment: Alignment.center, children: [
                    PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(value: online.toDouble(), color: _success, title: '', radius: 24),
                        PieChartSectionData(value: offline == 0 ? 0.001 : offline.toDouble(), color: _warning, title: '', radius: 24),
                      ],
                    )),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('$pct%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark)),
                      const Text('Online', style: TextStyle(fontSize: 11, color: _textGrey)),
                    ]),
                  ]),
                ),
                const SizedBox(width: 20),
                // Stats on the right
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$pct% Online',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: _success, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Online: $online devices', style: const TextStyle(fontSize: 13, color: _textGrey)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: _warning, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Offline: $offline devices', style: const TextStyle(fontSize: 13, color: _textGrey)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: _border, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Total: $total devices', style: const TextStyle(fontSize: 13, color: _textGrey)),
                    ]),
                  ],
                )),
              ]),
      ),
    );
  }
}

// ── Activity line chart ────────────────────────────────────────────────────────
class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard();

  @override
  Widget build(BuildContext context) {
    // Placeholder data points for 24 hours
    final onlineSpots  = List.generate(8, (i) => FlSpot(i.toDouble(), [3,4,4,5,4,5,6,5][i].toDouble()));
    final offlineSpots = List.generate(8, (i) => FlSpot(i.toDouble(), [2,2,1,1,2,1,1,2][i].toDouble()));

    return _Card(
      title: 'Device Activity — Last 24 hrs',
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(color: _border, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: _textGrey)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, getTitlesWidget: (v, _) {
                const labels = ['0h','3h','6h','9h','12h','15h','18h','21h'];
                final i = v.toInt();
                return i >= 0 && i < labels.length ? Text(labels[i], style: const TextStyle(fontSize: 9, color: _textGrey)) : const SizedBox();
              })),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(spots: onlineSpots,  color: _primary,  isCurved: true, curveSmoothness: 0.4, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: _primary.withValues(alpha: 0.08))),
              LineChartBarData(spots: offlineSpots, color: _warning, isCurved: true, curveSmoothness: 0.4, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: _warning.withValues(alpha: 0.08))),
            ],
          )),
        ),
      ),
      footer: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Legend(color: _primary, label: 'Online'),
        const SizedBox(width: 20),
        _Legend(color: _warning, label: 'Offline'),
      ]),
    );
  }
}

// ── Customer table ─────────────────────────────────────────────────────────────
class _CustomerTable extends StatelessWidget {
  const _CustomerTable({required this.stream});
  final AsyncValue<List<Map<String, dynamic>>> stream;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: stream.when(
        loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e', style: const TextStyle(color: _critical))),
        data: (list) {
          if (list.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No customers yet. Add one to get started.', style: TextStyle(color: _textGrey))),
            );
          }
          return Column(children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(color: _bg, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              child: const Row(children: [
                Expanded(flex: 3, child: Text('Customer',  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
                Expanded(flex: 2, child: Text('Devices',   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
                Expanded(flex: 2, child: Text('Status',    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
                SizedBox(width: 72, child: Text('Action',  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
              ]),
            ),
            const Divider(height: 1, color: _border),
            ...list.asMap().entries.map((e) {
              final c      = e.value;
              final isLast = e.key == list.length - 1;
              final active = (c['status'] as String? ?? 'active') == 'active';
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Expanded(flex: 3, child: Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _primary.withValues(alpha: 0.1),
                        child: Text((c['name'] as String? ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primary)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c['name'] as String? ?? 'Unknown', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textDark), overflow: TextOverflow.ellipsis),
                        Text(c['email'] as String? ?? '', style: const TextStyle(fontSize: 11, color: _textGrey), overflow: TextOverflow.ellipsis),
                      ])),
                    ])),
                    Expanded(flex: 2, child: Text('—', style: const TextStyle(color: _textGrey, fontSize: 13))),
                    Expanded(flex: 2, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: active ? const Color(0xFFE8F8EF) : const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(10)),
                      child: Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? _success : _critical)),
                    )),
                    SizedBox(width: 72, child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('View'),
                    )),
                  ]),
                ),
                if (!isLast) const Divider(height: 1, color: _border),
              ]);
            }),
          ]);
        },
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────
class _StatCard extends ConsumerWidget {
  const _StatCard({required this.label, required this.icon, required this.color, required this.value});
  final String label;
  final IconData icon;
  final Color color;
  final AsyncValue<int> value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey))),
          Icon(icon, size: 18, color: color),
        ]),
        value.when(
          data: (n) => Text('$n', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
          loading: () => const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => const Text('—', style: TextStyle(fontSize: 28, color: _textGrey)),
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.footer});
  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
        const SizedBox(height: 10),
        child,
        if (footer != null) ...[const SizedBox(height: 10), footer!],
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: _textGrey)),
    ]);
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ── Placeholder screens ────────────────────────────────────────────────────────
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.construction_outlined, size: 48, color: Colors.grey[400]),
      const SizedBox(height: 12),
      Text('$label — coming soon', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
    ]),
  );
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.settings_outlined, size: 48, color: _textGrey),
      const SizedBox(height: 16),
      const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textDark)),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: onSignOut,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(foregroundColor: _critical, side: const BorderSide(color: _critical), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      ),
    ]),
  );
}
