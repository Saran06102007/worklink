import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worklink/app.dart';
import 'package:worklink/state/app_state.dart';

void main() {
  testWidgets('App boots to splash then role select', (tester) async {
    final state = AppState(autoRespond: false, fastTiming: true);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const WorkLinkApp(),
      ),
    );
    expect(find.text('WorkLink'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('How will you use'), findsOneWidget);
    state.dispose();
  });
}
