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

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});
  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _college = TextEditingController();
  final _course = TextEditingController();
  String _year = '1st year';
  Set<String> _interests = {};
  Set<String> _slots = {};
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pw.dispose();
    _college.dispose();
    _course.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    context.read<AppState>().registerStudent(
          name: _name.text,
          phone: _phone.text,
          email: _email.text,
          password: _pw.text,
          college: _college.text,
          course: _course.text,
          year: _year,
          interests: _interests,
          slots: _slots,
        );
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return DarkZone(
      child: AppScaffold(
        title: 'Join as student',
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AppField(controller: _name, label: 'Full name', validator: vName),
                const SizedBox(height: 12),
                AppField(controller: _phone, label: 'Mobile', validator: vPhone, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                AppField(controller: _email, label: 'Email', validator: vEmail, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                AppField(controller: _pw, label: 'Password', validator: vPassword, obscure: true),
                const SizedBox(height: 12),
                AppField(controller: _college, label: 'College', validator: vRequired),
                const SizedBox(height: 12),
                AppField(controller: _course, label: 'Course', validator: vRequired),
                const SizedBox(height: 14),
                Text('Year', style: Ty.label(p.textDim)),
                const SizedBox(height: 6),
                ChipSelect(
                  options: const ['1st year', '2nd year', '3rd year', '4th year'],
                  selected: {_year},
                  multi: false,
                  onChanged: (s) {
                    if (s.isNotEmpty) setState(() => _year = s.first);
                  },
                ),
                const SizedBox(height: 14),
                Text('Interests', style: Ty.label(p.textDim)),
                const SizedBox(height: 6),
                ChipSelect(options: kStudentTypes, selected: _interests, onChanged: (s) => setState(() => _interests = s)),
                const SizedBox(height: 14),
                Text('Preferred slots', style: Ty.label(p.textDim)),
                const SizedBox(height: 6),
                ChipSelect(
                  options: [for (final d in kDays) for (final s in kSlots) '$d·$s'],
                  selected: _slots,
                  onChanged: (s) => setState(() => _slots = s),
                ),
                const SizedBox(height: 28),
                AppButton('Create account', onPressed: _submit, loading: _busy),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
