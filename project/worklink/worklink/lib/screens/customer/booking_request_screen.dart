import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/forms.dart';
import '../../widgets/ui.dart';
import 'customer_booking_detail.dart';

class BookingRequestScreen extends StatefulWidget {
  final String categoryId;
  final Worker? worker;
  final bool viaNearest;
  const BookingRequestScreen({super.key, required this.categoryId, this.worker, this.viaNearest = false});
  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final _form = GlobalKey<FormState>();
  final _details = TextEditingController();
  final _address = TextEditingController();
  final _offer = TextEditingController();
  String _schedule = 'ASAP';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final cat = categoryById(widget.categoryId);
    final base = widget.worker?.price ?? cat.basePrice;
    _offer.text = '$base';
    final c = context.read<AppState>().customer;
    _address.text = c?.address.isNotEmpty == true ? c!.address : '${c?.areaName ?? ''} (sample address)';
  }

  @override
  void dispose() {
    _details.dispose();
    _address.dispose();
    _offer.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final s = context.read<AppState>();
    final b = s.createBooking(
      categoryId: widget.categoryId,
      worker: widget.worker,
      details: _details.text,
      address: _address.text,
      schedule: _schedule,
      offer: int.parse(_offer.text.trim()),
      viaNearest: widget.viaNearest || widget.worker == null,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CustomerBookingDetailScreen(bookingId: b.id)));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final cat = categoryById(widget.categoryId);
    final w = widget.worker;

    return AppScaffold(
      title: 'Request ${cat.name}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (w != null)
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Avatar(w.name, seed: w.seed, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(w.name, style: Ty.title(p.text)),
                      Text('Usual ${rupees(w.price)}/${w.unit}', style: Ty.small(p.textDim)),
                    ]),
                  ),
                  VerificationBadge(w.verification, compact: true),
                ]),
              )
            else
              GlassCard(
                child: Text('We will fan out to the nearest verified ${cat.name.toLowerCase()}.', style: Ty.body(p.textDim)),
              ),
            const SizedBox(height: 16),
            AppField(controller: _details, label: 'What do you need?', maxLines: 3, validator: vMin(10, 'Details'), hint: 'Describe the job…'),
            const SizedBox(height: 12),
            AppField(controller: _address, label: 'Address', validator: vRequired),
            const SizedBox(height: 12),
            Text('When', style: Ty.label(p.textDim)),
            const SizedBox(height: 6),
            ChipSelect(
              options: const ['ASAP', 'Today evening', 'Tomorrow morning', 'This weekend'],
              selected: {_schedule},
              multi: false,
              onChanged: (set) {
                if (set.isNotEmpty) setState(() => _schedule = set.first);
              },
            ),
            const SizedBox(height: 12),
            AppField(
              controller: _offer,
              label: 'Your offer (₹)',
              validator: vAmount,
              keyboardType: TextInputType.number,
              prefix: Icons.currency_rupee_rounded,
            ),
            const SizedBox(height: 24),
            AppButton('Send request', onPressed: _submit, loading: _busy, icon: Icons.send_rounded),
          ]),
        ),
      ),
    );
  }
}
