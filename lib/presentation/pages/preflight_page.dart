import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plane_messenger/domain/services/notification_service.dart';
import 'package:plane_messenger/domain/services/system_service.dart';
import 'package:plane_messenger/main.dart';
import 'package:plane_messenger/presentation/pages/error_page.dart';
import 'package:plane_messenger/presentation/pages/radar_page.dart';

/// Checks that all required permissions are granted and hardware services
/// (Location, Bluetooth, Wi-Fi) are enabled before initializing the mesh layer.
///
/// Shows a dialog for each missing requirement with a button to open the
/// relevant system settings page. Nothing is enabled automatically.
class PreflightPage extends StatefulWidget {
  const PreflightPage({super.key});

  @override
  State<PreflightPage> createState() => _PreflightPageState();
}

class _PreflightPageState extends State<PreflightPage>
    with WidgetsBindingObserver {

  /// True while the user is in a system settings screen so that we re-run the
  /// preflight check when they return to the app.
  bool _awaitingReturn = false;

  SystemService get _systemService => getIt<SystemService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runPreflight();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingReturn) {
      _awaitingReturn = false;
      _runPreflight();
    }
  }

  Future<void> _runPreflight() async {
    if (!await _ensurePermissions()) return;

    if (!await _ensureServiceEnabled(
      name: 'Location',
      reason:
          'Location services must be enabled for peer discovery to work.',
      isEnabled: () => Permission.location.serviceStatus.isEnabled,
      openSettings: () => _systemService.openLocationSettings(),
    )) { return; }

    if (!await _ensureServiceEnabled(
      name: 'Bluetooth',
      reason:
          'Bluetooth is needed to discover and connect with nearby devices.',
      isEnabled: () => Permission.bluetooth.serviceStatus.isEnabled,
      openSettings: () => _systemService.openBluetoothSettings(),
    )) { return; }

    if (!await _ensureServiceEnabled(
      name: 'Wi-Fi',
      reason: 'Wi-Fi is required for high-speed mesh communication.',
      isEnabled: () => _systemService.isWifiEnabled,
      openSettings: () => _systemService.openWifiSettings(),
    )) { return; }

    if (!mounted) return;
    await getIt<NotificationService>().requestPermission();
    if (!mounted) return;
    try {
      await initializeMesh();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RadarPage()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ErrorPage(error: e.toString())),
      );
    }
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.locationWhenInUse,
      Permission.location,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices,
    ].request();

    final denied = <String>[];
    final checks = {
      'Location': Permission.location,
      'Bluetooth Advertise': Permission.bluetoothAdvertise,
      'Bluetooth Connect': Permission.bluetoothConnect,
      'Bluetooth Scan': Permission.bluetoothScan,
    };

    for (final entry in checks.entries) {
      final status = statuses[entry.value];
      if (status == null || !status.isGranted) {
        denied.add(entry.key);
      }
    }
    if (denied.isEmpty) return true;

    if (!mounted) return false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(
          'SkyMesh needs the following permissions:\n'
          '${denied.map((d) => '\u2022 $d').join('\n')}\n\n'
          'Please grant them in Settings.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _awaitingReturn = true;
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return false;
  }

  Future<bool> _ensureServiceEnabled({
    required String name,
    required String reason,
    required Future<bool> Function() isEnabled,
    required Future<void> Function() openSettings,
  }) async {
    if (await isEnabled()) return true;
    if (!mounted) return false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('$name is Off'),
        content: Text(reason),
        actions: [
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _awaitingReturn = true;
              await openSettings();
            },
            child: Text('Turn On $name'),
          ),
        ],
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking requirements...'),
          ],
        ),
      ),
    );
  }
}
