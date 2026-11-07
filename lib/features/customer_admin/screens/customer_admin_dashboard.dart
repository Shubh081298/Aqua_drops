import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/repositories/auth_repository.dart';
import '../providers/customer_admin_providers.dart';

const _primary  = Color(0xFF1769AA);
const _bg       = Color(0xFFF5F8FC);
const _border   = Color(0xFFE3EAF2);
const _textDark = Color(0xFF172B4D);
const _textGrey = Color(0xFF718096);
const _success  = Color(0xFF219653);
const _warning  = Color(0xFFF2A900);
const _critical = Color(0xFFDC4545);

class CustomerAdminDashboard extends ConsumerStatefulWidget {
  const CustomerAdminDashboard({super.key});
  @override
  ConsumerState<CustomerAdminDashboard> createState() => _CustomerAdminDashboardState();
}

class _CustomerAdminDashboardState extends ConsumerState<CustomerAdminDashboard> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined,     label: 'Dashboard'),
    _NavItem(icon: Icons.water_outlined,          label: 'My Tanks'),
    _NavItem(icon: Icons.people_outline,          label: 'Users'),
    _NavItem(icon: Icons.notifications_outlined, label: 'Alerts'),
    _NavItem(icon: Icons.settings_outlined,       label: 'Settings'),
  ];

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final name   = ref.watch(userDisplayNameProvider) ?? 'Admin';
    final isWide = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset('assets/images/aqua_drops_logo.png', height: 30, width: 30, fit: BoxFit.cover),
          ),
          const SizedBox(width: 8),
          const Text('Water Level Monitor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
            child: const Text('Customer Admin', style: TextStyle(fontSize: 11, color: Colors.white70)),
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
      ),
      body: isWide
          ? Row(children: [
              _Sidebar(items: _navItems, selected: _selectedIndex, onSelect: (i) => setState(() => _selectedIndex = i), onLogout: _signOut),
              Expanded(child: _body()),
            ])
          : _body(),
      bottomNavigationBar: isWide ? null : NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: _primary.withValues(alpha: 0.12),
        destinations: _navItems.map((n) => NavigationDestination(icon: Icon(n.icon), label: n.label)).toList(),
      ),
    );
  }

  Widget _body() => switch (_selectedIndex) {
    0 => const _DashboardTab(),
    1 => const _TanksTab(),
    4 => _SettingsTab(onSignOut: _signOut),
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
        ...items.asMap().entries.map((e) => _SidebarTile(
          item: e.value, selected: selected == e.key, onTap: () => onSelect(e.key),
        )),
        const Spacer(),
        const Divider(height: 1),
        _SidebarTile(
          item: const _NavItem(icon: Icons.logout, label: 'Logout'),
          selected: false, onTap: onLogout, danger: true,
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
    final tankCount  = ref.watch(myTankCountProvider);
    final online     = ref.watch(myOnlineTanksProvider);
    final alerts     = ref.watch(myAlertsProvider);
    final userCount  = ref.watch(myUserCountProvider);
    final tanks      = ref.watch(myTanksProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark)),
        const SizedBox(height: 16),

        // Stat cards
        LayoutBuilder(builder: (ctx, bc) {
          final cols = bc.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.7,
            children: [
              _StatCard(label: 'My Tanks',       icon: Icons.water_outlined,              color: _primary,  value: tankCount),
              _StatCard(label: 'Online Tanks',   icon: Icons.wifi,                        color: _success,  value: online),
              _StatCard(label: 'Active Alerts',  icon: Icons.notifications_active_outlined, color: _critical, value: alerts),
              _StatCard(label: 'Users',          icon: Icons.people_outline,              color: const Color(0xFF0288D1), value: userCount),
            ],
          );
        }),

        const SizedBox(height: 24),
        const Text('My Tanks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
        const SizedBox(height: 12),

        // Tank grid
        tanks.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: _critical)),
          data: (list) {
            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
                child: const Column(children: [
                  Icon(Icons.water_outlined, size: 48, color: Color(0xFFCBD5E0)),
                  SizedBox(height: 12),
                  Text('No tanks yet.', style: TextStyle(fontSize: 15, color: _textGrey)),
                  SizedBox(height: 4),
                  Text('Go to My Tanks → Add Tank to get started.', style: TextStyle(fontSize: 13, color: _textGrey)),
                ]),
              );
            }
            return LayoutBuilder(builder: (ctx, bc) {
              final cols = bc.maxWidth > 700 ? 3 : bc.maxWidth > 420 ? 2 : 1;
              return GridView.count(
                crossAxisCount: cols, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                children: list.map((t) => _TankCard(tank: t)).toList(),
              );
            });
          },
        ),
      ]),
    );
  }
}

// ── Tanks Tab ──────────────────────────────────────────────────────────────────
class _TanksTab extends ConsumerWidget {
  const _TanksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tanks = ref.watch(myTanksProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Tanks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark)),
            SizedBox(height: 2),
            Text('Monitor and manage your water tanks', style: TextStyle(fontSize: 13, color: _textGrey)),
          ])),
          FilledButton.icon(
            onPressed: () => _showAddTankDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Tank'),
            style: FilledButton.styleFrom(backgroundColor: _primary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        ]),
        const SizedBox(height: 16),

        Expanded(child: tanks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: _critical))),
          data: (list) {
            if (list.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.water_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                const Text('No tanks added yet.', style: TextStyle(fontSize: 16, color: _textGrey)),
                const SizedBox(height: 8),
                const Text('Click "Add Tank" to register your first tank.', style: TextStyle(fontSize: 13, color: _textGrey)),
              ]));
            }
            return LayoutBuilder(builder: (ctx, bc) {
              final cols = bc.maxWidth > 700 ? 3 : bc.maxWidth > 420 ? 2 : 1;
              return GridView.count(
                crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
                children: list.map((t) => _TankCard(tank: t, showDelete: true, ref: ref)).toList(),
              );
            });
          },
        )),
      ]),
    );
  }

  void _showAddTankDialog(BuildContext context, WidgetRef ref) {
    ref.read(addTankProvider.notifier).reset();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const _AddTankDialog());
  }
}

// ── Tank card ──────────────────────────────────────────────────────────────────
class _TankCard extends StatelessWidget {
  const _TankCard({required this.tank, this.showDelete = false, this.ref});
  final Map<String, dynamic> tank;
  final bool showDelete;
  final WidgetRef? ref;

  @override
  Widget build(BuildContext context) {
    final name     = tank['name']     as String? ?? 'Tank';
    final location = tank['location'] as String? ?? '—';
    final level    = (tank['level']   as num? ?? 0).toDouble();
    final capacity = (tank['capacity'] as num? ?? 100).toDouble();
    final status   = tank['status']   as String? ?? 'offline';
    final alert    = tank['alert']    as bool? ?? false;
    final pct      = capacity > 0 ? (level / capacity).clamp(0.0, 1.0) : 0.0;

    final statusColor = status == 'online' ? _success : _textGrey;
    final levelColor  = alert ? _critical : pct > 0.5 ? _success : pct > 0.2 ? _warning : _critical;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert ? _critical.withValues(alpha: 0.4) : _border),
        boxShadow: alert ? [BoxShadow(color: _critical.withValues(alpha: 0.1), blurRadius: 8)] : [],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark), overflow: TextOverflow.ellipsis)),
          if (alert) const Icon(Icons.warning_amber, size: 16, color: _critical),
          if (showDelete && ref != null)
            GestureDetector(
              onTap: () => ref!.read(addTankProvider.notifier).deleteTank(tank['id'] as String),
              child: const Icon(Icons.delete_outline, size: 16, color: _textGrey),
            ),
        ]),
        Row(children: [
          Icon(Icons.location_on_outlined, size: 12, color: _textGrey),
          const SizedBox(width: 2),
          Expanded(child: Text(location, style: const TextStyle(fontSize: 11, color: _textGrey), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 10),

        // Level bar
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, minHeight: 10,
              backgroundColor: const Color(0xFFE3EAF2),
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          )),
          const SizedBox(width: 8),
          Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: levelColor)),
        ]),
        const SizedBox(height: 6),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${level.toInt()} / ${capacity.toInt()} L', style: const TextStyle(fontSize: 11, color: _textGrey)),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
          ]),
        ]),
      ]),
    );
  }
}

// ── Add Tank dialog ────────────────────────────────────────────────────────────
class _AddTankDialog extends ConsumerStatefulWidget {
  const _AddTankDialog();
  @override
  ConsumerState<_AddTankDialog> createState() => _AddTankDialogState();
}

class _AddTankDialogState extends ConsumerState<_AddTankDialog> {
  final _formKey  = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _location = TextEditingController();
  final _capacity = TextEditingController(text: '1000');

  @override
  void dispose() { _name.dispose(); _location.dispose(); _capacity.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(addTankProvider.notifier).addTank(
      name: _name.text, location: _location.text,
      capacity: double.tryParse(_capacity.text) ?? 1000,
    );
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tank added successfully.'), backgroundColor: _success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTankProvider);
    return AlertDialog(
      title: const Text('Add New Tank', style: TextStyle(color: _textDark, fontSize: 17)),
      content: SizedBox(width: 360, child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (state.error != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(8), border: Border.all(color: _critical)),
            child: Row(children: [
              const Icon(Icons.error_outline, color: _critical, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(state.error!, style: const TextStyle(color: _critical, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        _Field(controller: _name,     label: 'Tank Name',       icon: Icons.water_outlined,       required: true),
        const SizedBox(height: 10),
        _Field(controller: _location, label: 'Location',         icon: Icons.location_on_outlined, required: true),
        const SizedBox(height: 10),
        _Field(controller: _capacity, label: 'Capacity (Litres)', icon: Icons.storage_outlined,
          keyboard: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Capacity is required';
            if (double.tryParse(v) == null) return 'Enter a valid number';
            return null;
          }),
      ]))),
      actions: [
        TextButton(onPressed: state.isLoading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _primary),
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Add Tank'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label, required this.icon, this.required = false, this.keyboard = TextInputType.text, this.validator});
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, size: 18),
        filled: true, fillColor: const Color(0xFFF7FAFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primary, width: 1.5)),
      ),
      validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
    );
  }
}

// ── Shared ─────────────────────────────────────────────────────────────────────
class _StatCard extends ConsumerWidget {
  const _StatCard({required this.label, required this.icon, required this.color, required this.value});
  final String label;
  final IconData icon;
  final Color color;
  final AsyncValue<int> value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
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

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.construction_outlined, size: 48, color: Colors.grey[400]),
    const SizedBox(height: 12),
    Text('$label — coming soon', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
  ]));
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.onSignOut});
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
  ]));
}
