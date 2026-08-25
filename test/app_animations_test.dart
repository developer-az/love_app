import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_special_app/utils/app_animations.dart';
import 'package:my_special_app/widgets/motion.dart';

void main() {
  testWidgets('fade route shows the next page without a slide', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  fadeRoute(const Scaffold(body: Text('Next screen'))),
                );
              },
              child: const Text('Go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pump();
    await tester.pump(AppAnimations.page);

    expect(find.text('Next screen'), findsOneWidget);
    expect(find.byType(SlideTransition), findsNothing);
  });

  testWidgets('reduce motion collapses animation duration', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            expect(AppAnimations.reduceMotion(context), isTrue);
            expect(
              AppAnimations.of(context, AppAnimations.medium),
              Duration.zero,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('fade switcher does not use slide transitions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FadeSwitcher(
            child: Text('Hello', key: ValueKey('hello')),
          ),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(SlideTransition), findsNothing);
    expect(find.byType(FadeTransition), findsWidgets);
  });
}
