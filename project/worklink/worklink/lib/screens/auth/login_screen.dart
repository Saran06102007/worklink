import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/forms.dart';
import '../../widgets/ui.dart';
import 'customer_register.dart';
import 'student_register.dart';
import 'worker_register.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final ok = context.read<AppState>().login(widget.role, _login.text, _pw.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = 'Invalid credentials for ${widget.role.label.toLowerCase()} role');
    } else {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  void _register() {
    Widget page;
    switch (widget.role) {
      case UserRole.customer:
        page = const CustomerRegisterScreen();
        break;
      case UserRole.worker:
        page = const WorkerRegisterScreen();
        break;
      case UserRole.student:
        page = const StudentRegisterScreen();
        break;
    }
    pushPage(context, page);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return DarkZone(
      child: AppScaffold(
        title: '${widget.role.label} sign in',
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Welcome back', style: Ty.h1(p.text)),
                const SizedBox(height: 6),
                Text('Use a demo account or sign in with your registered details.', style: Ty.body(p.textDim)),
                const SizedBox(height: 24),
                AppField(
                  controller: _login,
                  label: 'Email or phone',
                  hint: 'aarav@demo.worklink',
                  validator: vRequired,
                  prefix: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                AppField(
                  controller: _pw,
                  label: 'Password',
                  hint: 'demo123',
                  obscure: true,
                  validator: vPassword,
                  prefix: Icons.lock_outline_rounded,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: Ty.small(Brand.danger)),
                ],
                const SizedBox(height: 24),
                AppButton('Sign in', onPressed: _submit, loading: _busy, icon: Icons.login_rounded),
                const SizedBox(height: 12),
                AppButton('Use demo ${widget.role.label.toLowerCase()}',
                    onPressed: () {
                      context.read<AppState>().loginDemo(widget.role);
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    kind: BtnKind.secondary),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('New here? ', style: Ty.body(p.textDim)),
                  GestureDetector(
                    onTap: _register,
                    child: Text('Create account', style: Ty.title(p.accentSoft)),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
