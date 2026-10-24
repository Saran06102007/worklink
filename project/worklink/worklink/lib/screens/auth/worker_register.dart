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

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});
  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _bio = TextEditingController();
  final _price = TextEditingController(text: '350');
  final _years = TextEditingController(text: '3');
  String _cat = kCategories.first.id;
  String _unit = 'visit';
  Set<String> _skills = {};
  Set<String> _areas = {kAreas.first.name};
  int _step = 0;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pw.dispose();
    _bio.dispose();
    _price.dispose();
    _years.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_skills.isEmpty || _areas.isEmpty) {
      context.read<AppState>().toast('Pick skills and areas', error: true);
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    context.read<AppState>().registerWorker(
          name: _name.text,
          phone: _phone.text,
          email: _email.text,
          password: _pw.text,
          categoryId: _cat,
          years: int.tryParse(_years.text) ?? 1,
          skills: _skills.toList(),
          areaNames: _areas.toList(),
          price: int.tryParse(_price.text) ?? 300,
          unit: _unit,
          bio: _bio.text,
        );
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final skillOpts = kSkills[_cat] ?? [];
    return DarkZone(
      child: AppScaffold(
        title: 'Join as worker',
        body: SafeArea(
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: StepDots(total: 3, current: _step)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: _form,
                  child: _step == 0
                      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          AppField(controller: _name, label: 'Full name', validator: vName),
                          const SizedBox(height: 12),
                          AppField(controller: _phone, label: 'Mobile', validator: vPhone, keyboardType: TextInputType.phone),
                          const SizedBox(height: 12),
                          AppField(controller: _email, label: 'Email', validator: vEmail, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          AppField(controller: _pw, label: 'Password', validator: vPassword, obscure: true),
                        ])
                      : _step == 1
                          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Text('Trade', style: Ty.label(p.textDim)),
                              const SizedBox(height: 6),
                              ChipSelect(
                                options: kCategories.map((c) => c.name).toList(),
                                selected: {categoryById(_cat).name},
                                multi: false,
                                onChanged: (set) {
                                  if (set.isEmpty) return;
                                  final c = kCategories.firstWhere((c) => c.name == set.first);
                                  setState(() {
                                    _cat = c.id;
                                    _skills = {};
                                    _unit = c.unit;
                                    _price.text = '${c.basePrice}';
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              Text('Skills', style: Ty.label(p.textDim)),
                              const SizedBox(height: 6),
                              ChipSelect(options: skillOpts, selected: _skills, onChanged: (s) => setState(() => _skills = s)),
                              const SizedBox(height: 14),
                              AppField(controller: _years, label: 'Years of experience', keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              AppField(controller: _price, label: 'Base rate (₹)', keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              AppField(controller: _bio, label: 'Short bio', maxLines: 3, validator: vMin(20, 'Bio')),
                            ])
                          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Text('Service areas', style: Ty.label(p.textDim)),
                              const SizedBox(height: 6),
                              ChipSelect(
                                options: kAreas.map((a) => a.name).toList(),
                                selected: _areas,
                                onChanged: (s) => setState(() => _areas = s),
                              ),
                              const SizedBox(height: 16),
                              Text('After signup a simulated document review starts automatically.', style: Ty.small(p.textFaint)),
                            ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(children: [
                if (_step > 0)
                  Expanded(child: AppButton('Back', onPressed: () => setState(() => _step--), kind: BtnKind.secondary)),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    _step < 2 ? 'Continue' : 'Create account',
                    onPressed: () {
                      if (_step < 2) {
                        if (_form.currentState!.validate()) setState(() => _step++);
                      } else {
                        _submit();
                      }
                    },
                    loading: _busy,
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
