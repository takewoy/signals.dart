part of 'signals.dart';

// ignore: public_member_api_docs
void _debugPostEvent(
  String eventKind, [
  Map<Object?, Object?> event = const {},
]) {
  _initDevTools();
  if (_devToolsEnabled) {
    developer.postEvent(eventKind, event);
  }
}

bool _devToolsInitialized = false;
bool _devToolsEnabled = kDebugMode;

// ignore: public_member_api_docs
void _initDevTools() {
  if (!_devToolsEnabled || _devToolsInitialized) return;
  developer.registerExtension(
    'ext.signals.getAllNodes',
    (method, parameters) async {
      final signals = _signals
          .where((e) => e.target != null)
          .map((e) => e.target!)
          .map((e) => {
                'id': e.globalId,
                'label': e.debugLabel,
                'value': e.toString(),
                'type': 'signal',
              })
          .toList();
      final computed = _computed
          .where((e) => e.target != null)
          .map((e) => e.target!)
          .map((e) => {
                'id': e.globalId,
                'label': e.debugLabel,
                'value': e.toString(),
                'type': 'computed',
              })
          .toList();
      final effects = _effects
          .where((e) => e.target != null)
          .map((e) => e.target!)
          .map((e) => {
                'id': e.globalId,
                'label': e.debugLabel,
                'type': 'effect',
              })
          .toList();
      return developer.ServiceExtensionResponse.result(
        json.encode({
          'signals': signals,
          'computed': computed,
          'effects': effects,
          'nodes': [...signals, ...computed, ...effects]
        }),
      );
    },
  );
  developer.registerExtension(
    'ext.signals.getNode',
    (method, parameters) async {
      final id = int.parse(parameters['id']!);
      Map<String, dynamic>? result;
      for (final s in _signals) {
        if (s.target?.globalId == id) {
          final val = s.target!;
          result = {
            'id': val.globalId,
            'label': val.debugLabel,
            'value': val.toString(),
            'type': 'signal',
          };
          break;
        }
      }
      for (final s in _computed) {
        if (s.target?.globalId == id) {
          final val = s.target!;
          result = {
            'id': val.globalId,
            'label': val.debugLabel,
            'value': val.toString(),
            'type': 'computed',
          };
          break;
        }
      }
      for (final s in _effects) {
        if (s.target?.globalId == id) {
          final val = s.target!;
          result = {
            'id': val.globalId,
            'label': val.debugLabel,
            'type': 'effect',
          };
          break;
        }
      }
      return developer.ServiceExtensionResponse.result(
        json.encode({
          ...result ??
              {
                'id': id,
                'label': 'Disposed or does not exist',
              },
        }),
      );
    },
  );
  _devToolsInitialized = true;
}

Set<WeakReference<ReadonlySignal>> _signals = {};
void _onSignalCreated(Signal instance) {
  if (!_devToolsEnabled) return;
  if (_signals.any((e) => e.target == instance)) return;
  _signals.add(WeakReference(instance));
  _debugPostEvent('signals:signal', {
    'id': instance.globalId,
    'label': instance.debugLabel,
  });
}

Set<WeakReference<Computed>> _computed = {};
void _onComputedCreated(Computed instance) {
  if (!_devToolsEnabled) return;
  if (_computed.any((e) => e.target == instance)) return;
  _computed.add(WeakReference(instance));
  _debugPostEvent('signals:computed', {
    'id': instance.globalId,
    'label': instance.debugLabel,
  });
}

Set<WeakReference<_Effect>> _effects = {};
void _onEffectCreated(_Effect instance) {
  if (!_devToolsEnabled) return;
  if (_effects.any((e) => e.target == instance)) return;
  _effects.add(WeakReference(instance));
  _debugPostEvent('signals:effect', {
    'id': instance.globalId,
    'label': instance.debugLabel,
  });
}
