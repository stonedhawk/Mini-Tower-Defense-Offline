import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/features/results/result_screen.dart';

void main() {
  group('wavesCleared', () {
    test('a loss does not count the wave it happened in', () {
      expect(wavesCleared(didWin: false, waveReached: 1), 0);
      expect(wavesCleared(didWin: false, waveReached: 8), 7);
      expect(wavesCleared(didWin: false, waveReached: 10), 9);
    });

    test('a win counts every wave reached', () {
      expect(wavesCleared(didWin: true, waveReached: 10), 10);
    });

    test('never goes below zero', () {
      expect(wavesCleared(didWin: false, waveReached: 0), 0);
    });
  });

  group('ResultScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('a loss during wave 8 shows 7 waves cleared', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(levelId: 1, didWin: false, waveReached: 8),
      ));
      await tester.pumpAndSettle();

      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.text('Waves Cleared: 7'), findsOneWidget);
    });

    testWidgets('a win after wave 10 shows 10 waves cleared', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(levelId: 1, didWin: true, waveReached: 10),
      ));
      await tester.pumpAndSettle();

      expect(find.text('VICTORY'), findsOneWidget);
      expect(find.text('Waves Cleared: 10'), findsOneWidget);
    });

    testWidgets('an endless loss during wave 13 shows 12 waves survived',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(
          levelId: 1,
          didWin: false,
          waveReached: 13,
          isEndlessMode: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Waves Survived: 12'), findsOneWidget);
      expect(find.text('Best Wave: 13'), findsOneWidget);
    });
  });
}
