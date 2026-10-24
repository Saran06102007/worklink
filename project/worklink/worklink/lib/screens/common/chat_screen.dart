import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class ChatScreen extends StatefulWidget {
  final String bookingId;
  const ChatScreen({super.key, required this.bookingId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final s = context.read<AppState>();
    final from = s.role == UserRole.customer ? Party.customer : Party.worker;
    s.sendMessage(widget.bookingId, from, t);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: Dur.base, curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final b = s.bookingById(widget.bookingId);
    final p = Pal.of(context);
    if (b == null) return AppScaffold(title: 'Chat', body: const Center(child: Text('Not found')));

    final mineRole = s.role == UserRole.customer ? 'customer' : 'worker';

    return AppScaffold(
      title: 'Chat',
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: b.chat.length + (b.typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (b.typing && i == b.chat.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Pill('typing…', color: p.textFaint),
                  ),
                );
              }
              final m = b.chat[i];
              final mine = m.from == mineRole;
              final system = m.from == 'system';
              if (system) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: Text(m.text, style: Ty.small(p.textFaint), textAlign: TextAlign.center)),
                );
              }
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    gradient: mine ? Brand.primaryGradient : null,
                    color: mine ? null : p.surface.op(p.dark ? 0.9 : 1),
                    borderRadius: BorderRadius.circular(16),
                    border: mine ? null : Border.all(color: p.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(m.text, style: Ty.body(mine ? Colors.white : p.text)),
                    const SizedBox(height: 2),
                    Text(clock(m.at), style: Ty.small(mine ? Colors.white.op(0.7) : p.textFaint)),
                  ]),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: Ty.body(p.text),
                  decoration: InputDecoration(
                    hintText: 'Message…',
                    hintStyle: Ty.body(p.textFaint),
                    filled: true,
                    fillColor: p.surface.op(p.dark ? 0.85 : 1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.pill), borderSide: BorderSide(color: p.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.pill), borderSide: BorderSide(color: p.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onTap: _send,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(gradient: Brand.primaryGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
