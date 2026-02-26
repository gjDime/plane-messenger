import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plane_messenger/main.dart';
import 'package:plane_messenger/presentation/pages/error_page.dart';
import 'package:plane_messenger/presentation/pages/radar_page.dart';

/// Checks that all required permissions are granted and hardware services
/// (Location, Bluetooth) are enabled before initializing the mesh layer.
///
/// Shows a dialog for each missing requirement and re-checks when the user
/// returns from settings or taps "Retry".
class PreflightPage extends StatefulWidget {
  const PreflightPage({super.key});

  @override
  State<PreflightPage> createState() => _PreflightPageState();
}

class _PreflightPageState extends State<PreflightPage>
    with WidgetsBindingObserver {
  /// True while the user is in the system Settings app.
  bool _awaitingReturn = false;

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

  // ---------------------------------------------------------------------------
  // Preflight sequence
  // ---------------------------------------------------------------------------

  Future<void> _runPreflight() async {
    if (!await _ensurePermissions()) {
      return;
    }
    if (!await _ensureServiceEnabled(
      Permission.location,
      'Location',
      'Peer discovery requires Location services (GPS).',
    )) {
      return;
    }
    if (!await _ensureServiceEnabled(
      Permission.bluetooth,
      'Bluetooth',
      'Bluetooth is needed to connect with nearby devices.',
    )) {
      return;
    }

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

  // ---------------------------------------------------------------------------
  // Runtime permissions
  // ---------------------------------------------------------------------------

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
          TextButton(
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

  // ---------------------------------------------------------------------------
  // Hardware services (Location / Bluetooth)
  // ---------------------------------------------------------------------------

  Future<bool> _ensureServiceEnabled(
    PermissionWithService permission,
    String name,
    String reason,
  ) async {
    while (mounted && !await permission.serviceStatus.isEnabled) {
      if (!mounted) return false;
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Enable $name'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
      if (retry != true) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

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
