import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:plane_messenger/presentation/pages/error_page.dart';
import 'package:plane_messenger/presentation/pages/radar_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    debugPrint('[INIT] Starting app initialization...');

    // Step 1: Request permissions
    debugPrint('[INIT] Requesting permissions...');
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      throw Exception(
        'Required permissions not granted. Please enable Location and Bluetooth permissions.',
      );
    }
    debugPrint('[INIT] ✓ Permissions granted');

    // Step 2: Initialize Isar database
    debugPrint('[INIT] Initializing Isar database...');
    final isarService = IsarService();
    await isarService.openDB();
    getIt.registerSingleton<IsarService>(isarService);
    debugPrint('[INIT] ✓ Isar database initialized');

    // Step 3: Initialize KeyManager
    debugPrint('[INIT] Initializing KeyManager...');
    final keyManager = await KeyManager.instance;
    getIt.registerSingleton<KeyManager>(keyManager);
    debugPrint('[INIT] ✓ KeyManager initialized');

    // Step 4: Initialize ConnectionManager
    debugPrint('[INIT] Initializing ConnectionManager...');
    // Use the first 8 characters of the public key as a short device identifier
    const int kUserNameLength = 8;
    final connectionManager = ConnectionManager(
      userName: (await keyManager.publicKeyBase64).substring(0, kUserNameLength),
      onConnectionInitiated: (id, info) {
        // Auto-accept for MVP
        debugPrint('[P2P] Connection initiated with $id');
        getIt<ConnectionManager>().acceptConnection(id);
      },
      onConnectionResult: (id) {
        debugPrint('[P2P] Connected to $id');
        getIt<MeshRepositoryImpl>().onConnectionEstablished(id);
      },
      onDisconnected: (id) {
        debugPrint('[P2P] Disconnected from $id');
        getIt<MeshRepositoryImpl>().onPeerDisconnected(id);
      },
      onPayloadReceived: (id, payload) {
        debugPrint('[P2P] Payload received from $id');
        getIt<MeshRepositoryImpl>().onPayloadReceived(id, payload);
      },
    );
    getIt.registerSingleton<ConnectionManager>(connectionManager);
    debugPrint('[INIT] ✓ ConnectionManager initialized');

    // Step 5: Initialize MeshRepository
    debugPrint('[INIT] Initializing MeshRepository...');
    final meshRepo = MeshRepositoryImpl(
      connectionManager: connectionManager,
      isarService: isarService,
      keyManager: keyManager,
    );

    // Start Mesh (advertising and discovery)
    debugPrint('[INIT] Starting mesh network...');
    await meshRepo.initialize();
    getIt.registerSingleton<MeshRepositoryImpl>(meshRepo);
    debugPrint('[INIT] ✓ MeshRepository initialized');

    debugPrint('[INIT] ✓✓✓ All initialization complete! ✓✓✓');
  } catch (e, stackTrace) {
    initError = e.toString();
    debugPrint('[INIT] ✗✗✗ Initialization FAILED ✗✗✗');
    debugPrint('[INIT] Error: $e');
    debugPrint('[INIT] Stack trace:\n$stackTrace');
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
    debugPrint('[PERMISSIONS] $permission: $status');

    if (status == null || (!status.isGranted && !status.isLimited)) {
      debugPrint('[PERMISSIONS] Critical permission $permission not granted!');
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
                // Restart the app by popping all routes and rebuilding
                debugPrint('[RETRY] User requested retry, restarting app...');
                // For a full restart, we'd need to use a package like restart_app
                // For now, show a message
                debugPrint('[RETRY] Please restart the app manually to retry.');
              },
            )
          : const RadarPage(),
    );
  }
}
