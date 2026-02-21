import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/presentation/pages/error_page.dart';
import 'package:plane_messenger/presentation/pages/radar_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      throw Exception(
        'Required permissions not granted. Please enable Location and Bluetooth permissions.',
      );
    }

    final isarService = IsarService();
    await isarService.openDB();
    // Reset connection flags from the previous session. Records are kept so
    // that returning devices can be matched by public key and their stored
    // nicknames are preserved across restarts.
    await isarService.resetConnectionStatus();
    getIt.registerSingleton<IsarService>(isarService);

    final keyManager = await KeyManager.instance;
    getIt.registerSingleton<KeyManager>(keyManager);

    const int kUserNameLength = 8;
    final storedNickname = await UserPrefs.getNickname();
    final displayName = (storedNickname != null && storedNickname.isNotEmpty)
        ? storedNickname
        : (await keyManager.publicKeyBase64).substring(0, kUserNameLength);
    final connectionManager = ConnectionManager(
      userName: displayName,
      onConnectionInitiated: (id, info) {
        getIt<ConnectionManager>().acceptConnection(id);
      },
      onConnectionResult: (id) {
        getIt<MeshRepositoryImpl>().onConnectionEstablished(id);
      },
      onDisconnected: (id) {
        getIt<MeshRepositoryImpl>().onPeerDisconnected(id);
      },
      onPayloadReceived: (id, payload) {
        getIt<MeshRepositoryImpl>().onPayloadReceived(id, payload);
      },
    );
    getIt.registerSingleton<ConnectionManager>(connectionManager);

    final meshRepo = MeshRepositoryImpl(
      connectionManager: connectionManager,
      isarService: isarService,
      keyManager: keyManager,
    );
    await meshRepo.initialize();
    getIt.registerSingleton<MeshRepositoryImpl>(meshRepo);
  } catch (e, stackTrace) {
    initError = e.toString();
    debugPrint('[INIT] Error: $e\n$stackTrace');
  }

  runApp(MyApp(initError: initError));
}

Future<bool> _requestPermissions() async {
  final permissions = [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.nearbyWifiDevices,
  ];

  final statuses = await permissions.request();

  // Check if all critical permissions are granted
  final criticalPermissions = [
    Permission.location,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ];

  for (final permission in criticalPermissions) {
    final status = statuses[permission];
    if (status == null || (!status.isGranted && !status.isLimited)) {
      return false;
    }
  }

  return true;
}

class MyApp extends StatelessWidget {
  final String? initError;

  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyMesh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: initError != null
          ? ErrorPage(
              error: initError!,
              onRetry: () {
                // TODO: use a package like restart_app for a full restart
              },
            )
          : const RadarPage(),
    );
  }
}
