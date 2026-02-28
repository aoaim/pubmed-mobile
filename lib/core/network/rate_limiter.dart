import 'dart:async';

/// Token-bucket rate limiter.
class RateLimiter {
  RateLimiter({required this.maxPerSecond})
      : _tokens = maxPerSecond.toDouble(),
        _lastRefill = DateTime.now();

  final int maxPerSecond;
  double _tokens;
  DateTime _lastRefill;

  /// Waits until a token is available, then consumes one.
  Future<void> acquire() async {
    _refill();
    while (_tokens < 1) {
      // Wait until at least one token is available.
      final waitMs = ((1 - _tokens) / maxPerSecond * 1000).ceil();
      await Future.delayed(Duration(milliseconds: waitMs));
      _refill();
    }
    _tokens -= 1;
  }

  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill).inMilliseconds / 1000.0;
    _tokens = (_tokens + elapsed * maxPerSecond).clamp(0, maxPerSecond.toDouble());
    _lastRefill = now;
  }
}
