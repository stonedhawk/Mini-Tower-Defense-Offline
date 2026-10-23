import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/app/ftue_truth.dart';
import 'package:app/features/home/home_screen.dart';
import 'package:app/features/results/result_screen.dart';

// Runs [body] while collecting the FTUE_TRUTH lines it prints. debugPrint is
// restored before the test ends, which flutter_test checks.
Future<List<String>> _captureTruthLines(Future<void> Function() body) async {
  final truthLines = <String>[];
  final originalDebugPrint = debugPrint;
  FtueTruth.resetForTest();
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && message.startsWith(FtueTruth.linePrefix)) {
      truthLines.add(message);
    }
  };

  try {
    await body();
  } finally {
    debugPrint = originalDebugPrint;
    FtueTruth.resetForTest();
  }

  return truthLines;
}

void main() {
  group('FtueTruth.report', () {
    test('prints one FTUE_TRUTH line with the step id', () async {
      final lines = await _captureTruthLines(() async {
        FtueTruth.report(FtueStep.levelSelect);
        FtueTruth.report(FtueStep.gameOver);
      });

      expect(lines, [
        'FTUE_TRUTH step=level_select',
        'FTUE_TRUTH step=game_over',
      ]);
    });

    test('skips a step that repeats the last one', () async {
      final lines = await _captureTruthLines(() async {
        FtueTruth.report(FtueStep.emptyBattlefield);
        FtueTruth.report(FtueStep.emptyBattlefield);
        FtueTruth.report(FtueStep.buildMenu);
        FtueTruth.report(FtueStep.emptyBattlefield);
      });

      expect(lines, [
        'FTUE_TRUTH step=empty_battlefield',
        'FTUE_TRUTH step=build_menu',
        'FTUE_TRUTH step=empty_battlefield',
      ]);
    });

    test('prints nothing when not in debug mode', () async {
      final lines = await _captureTruthLines(() async {
        FtueTruth.report(FtueStep.levelSelect, isDebugMode: false);
        FtueTruth.report(FtueStep.defending, isDebugMode: false);
      });

      expect(lines, isEmpty);
    });

    test('every step id is lowercase snake_case', () {
      for (final step in FtueStep.values) {
        expect(step.id, matches(RegExp(r'^[a-z]+(_[a-z]+)*$')));
      }
    });
  });

  group('battlefieldStep', () {
    test('an empty map with no menu is the empty battlefield', () {
      expect(
        battlefieldStep(winOverlay: false, buildMenuOpen: false, hasBuiltTower: false),
        FtueStep.emptyBattlefield,
      );
    });

    test('a built tower makes it defending', () {
      expect(
        battlefieldStep(winOverlay: false, buildMenuOpen: false, hasBuiltTower: true),
        FtueStep.defending,
      );
    });

    test('an open build menu wins over the map, with or without towers', () {
      expect(
        battlefieldStep(winOverlay: false, buildMenuOpen: true, hasBuiltTower: false),
        FtueStep.buildMenu,
      );
      expect(
        battlefieldStep(winOverlay: false, buildMenuOpen: true, hasBuiltTower: true),
        FtueStep.buildMenu,
      );
    });

    test('the win overlay wins over everything, even an open build menu', () {
      expect(
        battlefieldStep(winOverlay: true, buildMenuOpen: true, hasBuiltTower: true),
        FtueStep.runEnd,
      );
      expect(
        battlefieldStep(winOverlay: true, buildMenuOpen: false, hasBuiltTower: false),
        FtueStep.runEnd,
      );
    });
  });

  group('screens report themselves', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('the level select reports once when it first shows', (tester) async {
      final lines = await _captureTruthLines(() async {
        await tester.pumpWidget(MaterialApp(
          navigatorObservers: [ftueRouteObserver],
          home: const HomeScreen(),
        ));
        await tester.pumpAndSettle();
      });

      expect(lines, ['FTUE_TRUTH step=level_select']);
    });

    testWidgets('a loss reports game over, then Back to Menu reports the level select once',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      final lines = await _captureTruthLines(() async {
        await tester.pumpWidget(MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [ftueRouteObserver],
          home: const HomeScreen(),
        ));
        await tester.pumpAndSettle();

        // Stands in for the game screen, which the result screen replaces.
        navigatorKey.currentState!.push(MaterialPageRoute<void>(
          builder: (context) => const Scaffold(body: Text('mission')),
        ));
        await tester.pumpAndSettle();
        navigatorKey.currentState!.pushReplacement(MaterialPageRoute<void>(
          builder: (context) =>
              const ResultScreen(levelId: 1, didWin: false, waveReached: 3),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Back to Menu'));
        await tester.pumpAndSettle();
      });

      expect(lines, [
        'FTUE_TRUTH step=level_select',
        'FTUE_TRUTH step=game_over',
        'FTUE_TRUTH step=level_select',
      ]);
    });

    testWidgets('a win reports unknown, since no step describes the victory screen',
        (tester) async {
      final lines = await _captureTruthLines(() async {
        await tester.pumpWidget(const MaterialApp(
          home: ResultScreen(levelId: 1, didWin: true, waveReached: 10),
        ));
        await tester.pumpAndSettle();
      });

      expect(lines, ['FTUE_TRUTH step=unknown']);
    });
  });
}
