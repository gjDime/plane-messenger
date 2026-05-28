import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../domain/repositories/peer_repository.dart';

class MeshForegroundService {
  final PeerRepository _peerRepository;
  StreamSubscription? _peerSub;

  MeshForegroundService({required PeerRepository peerRepository})
      : _peerRepository = peerRepository;

  Future<void> start() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'skymesh_foreground',
        channelName: 'SkyMesh Mesh Service',
        channelDescription: 'Keeps the mesh network alive in the background',
        channelImportance: NotificationChannelImportance.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    await FlutterForegroundTask.startService(
      serviceId: 888,
      notificationTitle: 'SkyMesh',
      notificationText: 'Mesh active \u2014 scanning for peers',
      callback: _keepAliveCallback,
    );

    _peerSub = _peerRepository.watchPeers().listen((peers) {
      final connected = peers.where((p) => p.isConnected).length;
      final text = connected == 0
          ? 'Mesh active \u2014 scanning for peers'
          : 'Mesh active \u2014 $connected peer${connected == 1 ? '' : 's'} connected';
      FlutterForegroundTask.updateService(notificationText: text);
    });
  }

  Future<void> stop() async {
    await _peerSub?.cancel();
    _peerSub = null;
    await FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void _keepAliveCallback() {
  FlutterForegroundTask.setTaskHandler(_KeepAliveTaskHandler());
}

class _KeepAliveTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
