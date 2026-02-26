import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:plane_messenger/core/security/crypto_service.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/presentation/pages/error_page.dart';
import 'package:plane_messenger/presentation/pages/preflight_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    // Phase 1: Storage and crypto — no permissions required.
    final isarService = IsarService();
    await isarService.openDB();
    await isarService.resetConnectionStatus();
    getIt.registerSingleton<IsarService>(isarService);

    final keyManager = await KeyManager.instance;
    getIt.registerSingleton<KeyManager>(keyManager);

    final cryptoService = CryptoService(keyManager: keyManager);
    getIt.registerSingleton<CryptoService>(cryptoService);
  } catch (e, stackTrace) {
    initError = e.toString();
    debugPrint('[INIT] Error: $e\n$stackTrace');
  }

  runApp(MyApp(initError: initError));
}

/// Phase 2: Mesh networking — called by [PreflightPage] after permissions and
/// hardware services have been verified.
Future<void> initializeMesh() async {
  if (getIt.isRegistered<MeshRepositoryImpl>()) return;

  final keyManager = getIt<KeyManager>();

  const kUserNameLength = 8;
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
    isarService: getIt<IsarService>(),
    keyManager: keyManager,
    cryptoService: getIt<CryptoService>(),
  );
  await meshRepo.initialize();
  getIt.registerSingleton<MeshRepositoryImpl>(meshRepo);
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
          ? ErrorPage(error: initError!)
          : const PreflightPage(),
    );
  }
}
