import 'package:book_sharing_app/models/sync_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncConfig', () {
    test('baseInterval is 2 minutes', () {
      expect(SyncConfig.baseInterval.inMinutes, 2);
    });

    test('maxInterval is 5 minutes', () {
      expect(SyncConfig.maxInterval.inMinutes, 5);
    });

    test('minInterval is 30 seconds', () {
      expect(SyncConfig.minInterval.inSeconds, 30);
    });

    test('batterySaverBaseInterval is 4 minutes', () {
      expect(SyncConfig.batterySaverBaseInterval.inMinutes, 4);
    });

    test('batterySaverMaxInterval is 10 minutes', () {
      expect(SyncConfig.batterySaverMaxInterval.inMinutes, 10);
    });

    test('highPriorityDebounce is zero', () {
      expect(SyncConfig.highPriorityDebounce.inSeconds, 0);
    });

    test('mediumPriorityDebounce is 2 seconds', () {
      expect(SyncConfig.mediumPriorityDebounce.inSeconds, 2);
    });

    test('lowPriorityDebounce is 5 seconds', () {
      expect(SyncConfig.lowPriorityDebounce.inSeconds, 5);
    });

    test('maxRetries is 5', () {
      expect(SyncConfig.maxRetries, 5);
    });

    test('initialRetryDelay is 1 second', () {
      expect(SyncConfig.initialRetryDelay.inSeconds, 1);
    });

    test('maxRetryDelay is 30 seconds', () {
      expect(SyncConfig.maxRetryDelay.inSeconds, 30);
    });

    test('inactivityThreshold is 5 minutes', () {
      expect(SyncConfig.inactivityThreshold.inMinutes, 5);
    });

    test('autoSuspendOnInactivity is true', () {
      expect(SyncConfig.autoSuspendOnInactivity, true);
    });

    test('syncOnlyOnWifi is false', () {
      expect(SyncConfig.syncOnlyOnWifi, false);
    });

    test('pauseOnNoConnection is true', () {
      expect(SyncConfig.pauseOnNoConnection, true);
    });
  });
}
