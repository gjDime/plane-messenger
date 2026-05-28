import 'package:flutter/services.dart';
import 'package:plane_messenger/domain/services/system_service.dart';

class AndroidSystemService implements SystemService {
  static const _systemChannel = MethodChannel('com.plane.messenger/system');
  static const _serviceEvents = EventChannel('com.plane.messenger/service_events');

  @override
  Stream<String> get serviceEventStream =>
      _serviceEvents.receiveBroadcastStream().map((e) => e as String);

  @override
  Future<bool> get isWifiEnabled async {
    try {
      return await _systemChannel.invokeMethod<bool>('isWifiEnabled') ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> openBluetoothSettings() =>
      _systemChannel.invokeMethod('openBluetoothSettings');

  @override
  Future<void> openLocationSettings() =>
      _systemChannel.invokeMethod('openLocationSettings');

  @override
  Future<void> openWifiSettings() =>
      _systemChannel.invokeMethod('openWifiSettings');
}
