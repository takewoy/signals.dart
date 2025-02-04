import 'dart:async';

import 'signals.dart';

/// Connects a [Stream] to a [Signal].
class Connect<T> {
  Connect(this.signal);
  final Signal<T> signal;
  final Map<int, StreamSubscription> _subscriptions = {};

  /// Connects a [Stream] to a [Signal].
  ///
  /// ```dart
  /// final counter = signal(0);
  /// final c = connect(counter);
  ///
  /// final s1 = Stream.value(1);
  /// final s2 = Stream.value(2);
  ///
  /// c.from(s1).from(s2);
  ///
  /// c.dispose();
  /// ```
  Connect<T> from(
    Stream<T> source, {
    bool? cancelOnError,
  }) {
    final subscription = source.listen(
      (event) {
        signal.value = event;
      },
      onDone: () {
        _subscriptions.removeWhere((key, value) => key == source.hashCode);
      },
      cancelOnError: cancelOnError,
    );
    _subscriptions[source.hashCode] = subscription;
    return this;
  }

  /// Synonym for `from(Stream<T> source)`
  Connect<T> operator <<(Stream<T> source) => from(source);

  /// Cancels all subscriptions.
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
  }
}

/// Connects a [Signal] to a [Stream].
Connect<T> connect<T>(Signal<T> signal) {
  return Connect(signal);
}
