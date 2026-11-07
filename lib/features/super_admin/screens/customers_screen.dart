import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/customers_provider.dart';

const _primary  = Color(0xFF1769AA);
const _bg       = Color(0xFFF5F8FC);
const _border   = Color(0xFFE3EAF2);
const _textDark = Color(0xFF172B4D);
const _textGrey = Color(0xFF718096);
const _success  = Color(0xFF219653);
const _critical = Color(0xFFDC4545);

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(filteredCustomersProvider);
    final query     = ref.watch(customerSearchProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──
        Row(children: [
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Customers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark)),
              SizedBox(height: 2),
              Text('Manage customer admins and their accounts', style: TextStyle(fontSize: 13, color: _textGrey)),
            ]),
          ),
          FilledButton.icon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Customer'),
            style: FilledButton.styleFrom(backgroundColor: _primary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        ]),
        const SizedBox(height: 16),

        // ── Search bar ──
        TextField(
          onChanged: (v) => ref.read(customerSearchProvider.notifier).state = v,
          decoration: InputDecoration(
            hintText: 'Search by name, email or company…',
            hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
            prefixIcon: const Icon(Icons.search, size: 18, color: _textGrey),
            suffixIcon: query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 16, color: _textGrey), onPressed: () => ref.read(customerSearchProvider.notifier).state = '')
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),

        // ── Table ──
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
            child: customers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: _critical))),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        query.isNotEmpty ? 'No customers match "$query"' : 'No customers yet.',
                        style: const TextStyle(fontSize: 15, color: _textGrey),
                      ),
                      if (query.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Click "Add Customer" to get started.', style: TextStyle(fontSize: 13, color: _textGrey)),
                      ],
                    ]),
                  );
                }
                return Column(children: [
                  _TableHeader(),
                  const Divider(height: 1, color: _border),
                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
                      itemBuilder: (_, i) => _CustomerRow(customer: list[i], ref: ref),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ),
      ]),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    ref.read(addCustomerProvider.notifier).reset();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const _AddCustomerDialog());
  }
}

// ── Table header ───────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(color: _bg, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      child: const Row(children: [
        Expanded(flex: 3, child: Text('Customer',  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
        Expanded(flex: 2, child: Text('Company',   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
        Expanded(flex: 2, child: Text('Phone',     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
        Expanded(flex: 1, child: Text('Status',    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
        SizedBox(width: 100,  child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey))),
      ]),
    );
  }
}

// ── Single row ─────────────────────────────────────────────────────────────────
class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer, required this.ref});
  final Map<String, dynamic> customer;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final uid     = customer['id'] as String;
    final name    = customer['name']    as String? ?? 'Unknown';
    final email   = customer['email']   as String? ?? '';
    final company = customer['company'] as String? ?? '—';
    final phone   = customer['phone']   as String? ?? '—';
    final status  = customer['status']  as String? ?? 'active';
    final active  = status == 'active';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [

        // Name + email
        Expanded(flex: 3, child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _primary.withValues(alpha: 0.1),
            child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primary)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textDark), overflow: TextOverflow.ellipsis),
            Text(email, style: const TextStyle(fontSize: 11, color: _textGrey), overflow: TextOverflow.ellipsis),
          ])),
        ])),

        Expanded(flex: 2, child: Text(company, style: const TextStyle(fontSize: 13, color: _textDark), overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(phone.isEmpty ? '—' : phone, style: const TextStyle(fontSize: 13, color: _textGrey))),

        // Status badge
        Expanded(flex: 1, child: GestureDetector(
          onTap: () => ref.read(addCustomerProvider.notifier).toggleStatus(uid, status),
          child: Tooltip(
            message: active ? 'Click to deactivate' : 'Click to activate',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFE8F8EF) : const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                active ? 'Active' : 'Inactive',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? _success : _critical),
              ),
            ),
          ),
        )),

        // Actions
        SizedBox(width: 100, child: Row(children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: _textGrey),
            tooltip: 'Edit',
            onPressed: () => _showEditDialog(context, uid, customer),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: _critical),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, uid, name),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ])),
      ]),
    );
  }

  void _showEditDialog(BuildContext context, String uid, Map<String, dynamic> data) {
    final nameCtrl    = TextEditingController(text: data['name']    as String? ?? '');
    final companyCtrl = TextEditingController(text: data['company'] as String? ?? '');
    final phoneCtrl   = TextEditingController(text: data['phone']   as String? ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Customer', style: TextStyle(color: _textDark)),
        content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _DialogField(controller: nameCtrl,    label: 'Name',         icon: Icons.person_outline),
          const SizedBox(height: 12),
          _DialogField(controller: companyCtrl, label: 'Company Name', icon: Icons.business_outlined),
          const SizedBox(height: 12),
          _DialogField(controller: phoneCtrl,   label: 'Phone',        icon: Icons.phone_outlined),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primary),
            onPressed: () async {
              await FirestoreUpdate.updateCustomer(uid, nameCtrl.text, companyCtrl.text, phoneCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _critical),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(addCustomerProvider.notifier).deleteCustomer(uid);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Add customer dialog ────────────────────────────────────────────────────────
class _AddCustomerDialog extends ConsumerStatefulWidget {
  const _AddCustomerDialog();
  @override
  ConsumerState<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<_AddCustomerDialog> {
  final _formKey     = GlobalKey<FormState>();
  final _name        = TextEditingController();
  final _email       = TextEditingController();
  final _password    = TextEditingController();
  final _company     = TextEditingController();
  final _phone       = TextEditingController();
  bool _obscure      = true;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose();
    _company.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(addCustomerProvider.notifier).addCustomer(
      name: _name.text, email: _email.text, password: _password.text,
      company: _company.text, phone: _phone.text,
    );
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully.'), backgroundColor: _success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCustomerProvider);
    return AlertDialog(
      title: const Text('Add New Customer', style: TextStyle(color: _textDark, fontSize: 17)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
              const SizedBox(height: 12),
            ],
            _DialogField(controller: _name,    label: 'Full Name',     icon: Icons.person_outline,   required: true),
            const SizedBox(height: 10),
            _DialogField(controller: _email,   label: 'Email Address', icon: Icons.email_outlined,    required: true, keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              }),
            const SizedBox(height: 10),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                filled: true, fillColor: const Color(0xFFF7FAFF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primary, width: 1.5)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),
            _DialogField(controller: _company, label: 'Company Name',  icon: Icons.business_outlined, required: true),
            const SizedBox(height: 10),
            _DialogField(controller: _phone,   label: 'Phone (optional)', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: state.isLoading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _primary),
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Add Customer'),
        ),
      ],
    );
  }
}

// ── Shared form field ──────────────────────────────────────────────────────────
class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.keyboard = TextInputType.text,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true, fillColor: const Color(0xFFF7FAFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primary, width: 1.5)),
      ),
      validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
    );
  }
}

// ── Firestore update helper (doesn't need notifier state) ─────────────────────
class FirestoreUpdate {
  static Future<void> updateCustomer(String uid, String name, String company, String phone) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name':      name.trim(),
      'company':   company.trim(),
      'phone':     phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
