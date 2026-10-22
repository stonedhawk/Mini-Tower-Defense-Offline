import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/features/home/home_screen.dart';

/// One screen setup the home screen must fit on.
class _ScreenCase {
  final String name;
  final Size physicalSize;
  final double devicePixelRatio;

  /// Physical pixels covered by cutouts, notches or the home indicator.
  final double leftInsetPixels;
  final double rightInsetPixels;
  final double bottomInsetPixels;
  final double textScale;

  const _ScreenCase({
    required this.name,
    required this.physicalSize,
    required this.devicePixelRatio,
    this.leftInsetPixels = 0,
    this.rightInsetPixels = 0,
    this.bottomInsetPixels = 0,
    this.textScale = 1.0,
  });
}

/// Counts pushed routes so a test can tell that a mission was started.
class _PushCounter extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
  }
}

const List<_ScreenCase> _screenCases = [
  // The Pixel emulator used for live ftue runs: 2400x1080 landscape with
  // a 135 pixel camera cutout on the left, reported as a safe area inset.
  _ScreenCase(
    name: '2400x1080 landscape with left cutout',
    physicalSize: Size(2400, 1080),
    devicePixelRatio: 2.625,
    leftInsetPixels: 135,
  ),
  // The same emulator as it actually runs today: Android keeps the app out
  // of the cutout, so the window is 2265x1080 with no insets.
  _ScreenCase(
    name: '2265x1080 landscape (cutout excluded)',
    physicalSize: Size(2265, 1080),
    devicePixelRatio: 2.625,
  ),
  // iPhone 15/16 class in landscape (852x393 points) with the notch and
  // home indicator insets.
  _ScreenCase(
    name: 'iPhone landscape 2556x1179',
    physicalSize: Size(2556, 1179),
    devicePixelRatio: 3.0,
    leftInsetPixels: 177,
    rightInsetPixels: 177,
    bottomInsetPixels: 63,
  ),
  // iPhone SE in landscape (667x375 points).
  _ScreenCase(
    name: 'iPhone SE landscape 1334x750',
    physicalSize: Size(1334, 750),
    devicePixelRatio: 2.0,
  ),
  // A short, older 16:9 phone in landscape (640x360 logical pixels).
  _ScreenCase(
    name: '1280x720 landscape',
    physicalSize: Size(1280, 720),
    devicePixelRatio: 2.0,
  ),
  // Portrait, in case the orientation lock is ever not applied (iOS iPad).
  _ScreenCase(
    name: '1080x2400 portrait',
    physicalSize: Size(1080, 2400),
    devicePixelRatio: 2.625,
  ),
  // Short landscape screen with large system font.
  _ScreenCase(
    name: '1280x720 landscape with 1.5x text',
    physicalSize: Size(1280, 720),
    devicePixelRatio: 2.0,
    textScale: 1.5,
  ),
];

Future<_PushCounter> _pumpHomeScreen(WidgetTester tester, _ScreenCase screen) async {
  tester.view.physicalSize = screen.physicalSize;
  tester.view.devicePixelRatio = screen.devicePixelRatio;
  final insets = FakeViewPadding(
    left: screen.leftInsetPixels,
    right: screen.rightInsetPixels,
    bottom: screen.bottomInsetPixels,
  );
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
  addTearDown(tester.view.reset);

  final pushCounter = _PushCounter();
  await tester.pumpWidget(
    MediaQuery.withClampedTextScaling(
      minScaleFactor: screen.textScale,
      maxScaleFactor: screen.textScale,
      child: MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        navigatorObservers: [pushCounter],
        home: const HomeScreen(),
      ),
    ),
  );
  // Let the best-wave load finish and the card scale-in animation end.
  await tester.pumpAndSettle();
  // Ignore the initial push of the home route itself.
  pushCounter.pushCount = 0;
  return pushCounter;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final screen in _screenCases) {
    testWidgets('Level cards fit with no overflow on ${screen.name}', (tester) async {
      await _pumpHomeScreen(tester, screen);

      expect(tester.takeException(), isNull);

      final startMissionLabel = find.text('START MISSION').first;
      final firstCard = find.byKey(const ValueKey('level-card-1'));
      expect(firstCard, findsOneWidget);

      final cardRect = tester.getRect(firstCard);
      final labelRect = tester.getRect(startMissionLabel);
      expect(cardRect.contains(labelRect.topLeft), isTrue,
          reason: 'START MISSION top-left $labelRect should be inside card $cardRect');
      expect(cardRect.contains(labelRect.bottomRight - const Offset(0.1, 0.1)), isTrue,
          reason: 'START MISSION bottom-right $labelRect should be inside card $cardRect');
    });

    testWidgets('Tapping START MISSION starts the mission on ${screen.name}', (tester) async {
      final pushCounter = await _pumpHomeScreen(tester, screen);

      // tap() only warns when it misses, so the push count is the real check.
      await tester.tap(find.text('START MISSION').first);
      await tester.pump();

      expect(pushCounter.pushCount, 1);
      expect(find.byType(GameScreen, skipOffstage: false), findsOneWidget);

      // Tear down before the Flame game starts loading sprites and ticking.
      await tester.pumpWidget(const SizedBox());
    });
  }
}
