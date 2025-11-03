import 'dart:async';

class InactivityManager {
  InactivityManager({required this.onTimeout, Duration? timeout})
      : _timeout = timeout ?? const Duration(minutes: 5);

  final Duration _timeout;
  final FutureOr<void> Function() onTimeout;

  Timer? _timer;

  void registerActivity() {
    _timer?.cancel();
    _timer = Timer(_timeout, () => onTimeout());
  }

  void updateTimeout(Duration timeout) {
    if (_timeout == timeout) {
      registerActivity();
      return;
    }
    _timer?.cancel();
    _timer = Timer(timeout, () => onTimeout());
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
