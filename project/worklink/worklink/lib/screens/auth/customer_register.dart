import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/forms.dart';
import '../../widgets/ui.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});
  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  Area _area = kAreas.first;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final s = context.read<AppState>();
    if (s.accountExists(UserRole.customer, _email.text, _phone.text)) {
      s.toast('Account already exists', error: true);
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    s.registerCustomer(
      name: _name.text,
      phone: _phone.text,
      email: _email.text,
      password: _pw.text,
      area: _area,
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return DarkZone(
      child: AppScaffold(
        title: 'Create customer account',
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AppField(controller: _name, label: 'Full name', validator: vName, prefix: Icons.badge_outlined),
                const SizedBox(height: 12),
                AppField(controller: _phone, label: 'Mobile', validator: vPhone, keyboardType: TextInputType.phone, prefix: Icons.phone_outlined),
                const SizedBox(height: 12),
                AppField(controller: _email, label: 'Email', validator: vEmail, keyboardType: TextInputType.emailAddress, prefix: Icons.email_outlined),
                const SizedBox(height: 12),
                AppField(controller: _pw, label: 'Password', validator: vPassword, obscure: true, prefix: Icons.lock_outline),
                const SizedBox(height: 16),
                Text('Area', style: Ty.label(p.textDim)),
                const SizedBox(height: 6),
                ChipSelect(
                  options: kAreas.map((a) => a.name).toList(),
                  selected: {_area.name},
                  multi: false,
                  onChanged: (set) {
                    if (set.isEmpty) return;
                    setState(() => _area = kAreas.firstWhere((a) => a.name == set.first));
                  },
                ),
                const SizedBox(height: 28),
                AppButton('Create account', onPressed: _submit, loading: _busy, icon: Icons.person_add_alt_1_rounded),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
