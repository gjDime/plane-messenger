import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:plane_messenger/core/security/crypto_service.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/core/storage/flutter_secure_storage_service.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/datasources/local/isar_database.dart';
import 'package:plane_messenger/data/datasources/local/isar_game_repository.dart';
import 'package:plane_messenger/data/datasources/local/isar_group_repository.dart';
import 'package:plane_messenger/data/datasources/local/isar_message_repository.dart';
import 'package:plane_messenger/data/datasources/local/isar_peer_repository.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/datasources/platform/android_system_service.dart';
import 'package:plane_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:plane_messenger/core/active_screen_tracker.dart';
import 'package:plane_messenger/data/services/game_handler.dart';
import 'package:plane_messenger/data/services/group_management_handler.dart';
import 'package:plane_messenger/data/services/local_notification_service.dart';
import 'package:plane_messenger/data/services/message_router.dart';
import 'package:plane_messenger/data/services/mesh_foreground_service.dart';
import 'package:plane_messenger/data/services/notification_coordinator.dart';
import 'package:plane_messenger/domain/repositories/game_repository.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/mesh_repository.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/encryption_service.dart';
import 'package:plane_messenger/domain/services/notification_service.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/secure_storage_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';
import 'package:plane_messenger/domain/services/system_service.dart';
import 'package:plane_messenger/presentation/pages/error_page.dart';
import 'package:plane_messenger/presentation/pages/preflight_page.dart';
import 'package:plane_messenger/presentation/viewmodels/chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/game_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/group_chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/radar_viewmodel.dart';

final getIt = GetIt.instance;
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    // Phase 1: Storage and crypto — no permissions required.
    final storage = const FlutterSecureStorageService();
    getIt.registerSingleton<SecureStorageService>(storage);

    final userPrefs = UserPrefs(storage);
    getIt.registerSingleton<UserPrefs>(userPrefs);

    final systemService = AndroidSystemService();
    getIt.registerSingleton<SystemService>(systemService);

    final isarDb = IsarDatabase();
    await isarDb.instance; // ensure DB is open

    final peerRepo = IsarPeerRepository(isarDb);
    await peerRepo.resetConnectionStatus();
    getIt.registerSingleton<PeerRepository>(peerRepo);

    final messageRepo = IsarMessageRepository(isarDb);
    getIt.registerSingleton<MessageRepository>(messageRepo);

    final gameRepo = IsarGameRepository(isarDb);
    getIt.registerSingleton<GameRepository>(gameRepo);

    final groupRepo = IsarGroupRepository(isarDb);
    getIt.registerSingleton<GroupRepository>(groupRepo);

    final keyManager = await KeyManager.create(storage);
    getIt.registerSingleton<SigningService>(keyManager);

    final cryptoService = CryptoService(signingService: keyManager);
    getIt.registerSingleton<EncryptionService>(cryptoService);

    final screenTracker = ActiveScreenTracker();
    getIt.registerSingleton<ActiveScreenTracker>(screenTracker);

    final notificationService = LocalNotificationService();
    await notificationService.initialize();
    getIt.registerSingleton<NotificationService>(notificationService);
  } catch (e, stackTrace) {
    initError = e.toString();
    debugPrint('[INIT] Error: $e\n$stackTrace');
  }

  runApp(MyApp(initError: initError));
}

/// Phase 2: Mesh networking — called by [PreflightPage] after permissions and
/// hardware services have been verified.
Future<void> initializeMesh() async {
  if (getIt.isRegistered<MeshRepository>()) return;

  final signingService = getIt<SigningService>();
  final userPrefs = getIt<UserPrefs>();

  const kUserNameLength = 8;
  final storedNickname = await userPrefs.getNickname();
  final displayName = (storedNickname != null && storedNickname.isNotEmpty)
      ? storedNickname
      : (await signingService.publicKeyBase64).substring(0, kUserNameLength);

  late final ConnectionManager connectionManager;
  connectionManager = ConnectionManager(
    userName: displayName,
    onConnectionInitiated: (id, info) {
      getIt<P2PConnectionService>().acceptConnection(id);
    },
    onConnectionResult: (id) {
      connectionManager.markConnected(id);
      getIt<MeshRepository>().onConnectionEstablished(id);
    },
    onDisconnected: (id) {
      connectionManager.markDisconnected(id);
      getIt<MeshRepository>().onPeerDisconnected(id);
    },
    onPayloadReceived: (id, payload) {
      getIt<MeshRepository>().onPayloadReceived(id, payload);
    },
  );
  getIt.registerSingleton<P2PConnectionService>(connectionManager);

  final meshRepo = MeshRepositoryImpl(
    connectionService: connectionManager,
    messageRepository: getIt<MessageRepository>(),
    peerRepository: getIt<PeerRepository>(),
    signingService: signingService,
    encryptionService: getIt<EncryptionService>(),
    userPrefs: userPrefs,
    gameRepository: getIt<GameRepository>(),
    groupRepository: getIt<GroupRepository>(),
  );
  await meshRepo.initialize();
  getIt.registerSingleton<MeshRepository>(meshRepo);
  getIt.registerSingleton<GameHandler>(meshRepo.gameHandler);
  getIt.registerSingleton<GroupManagementHandler>(meshRepo.groupManagementHandler);
  getIt.registerSingleton<MessageRouter>(meshRepo.messageRouter);

  final coordinator = NotificationCoordinator(
    notificationService: getIt<NotificationService>(),
    screenTracker: getIt<ActiveScreenTracker>(),
    messageRouter: getIt<MessageRouter>(),
    gameHandler: getIt<GameHandler>(),
    groupMgmtHandler: getIt<GroupManagementHandler>(),
    peerRepository: getIt<PeerRepository>(),
    groupRepository: getIt<GroupRepository>(),
    signingService: getIt<SigningService>(),
  );
  await coordinator.initialize();
  getIt.registerSingleton<NotificationCoordinator>(coordinator);

  final foregroundService = MeshForegroundService(
    peerRepository: getIt<PeerRepository>(),
  );
  await foregroundService.start();
  getIt.registerSingleton<MeshForegroundService>(foregroundService);

  // Register ViewModels — created after mesh is initialized.
  getIt.registerFactory<RadarViewModel>(() => RadarViewModel(
    meshRepository: getIt<MeshRepository>(),
    peerRepository: getIt<PeerRepository>(),
    messageRepository: getIt<MessageRepository>(),
    connectionService: getIt<P2PConnectionService>(),
    signingService: getIt<SigningService>(),
    userPrefs: getIt<UserPrefs>(),
    systemService: getIt<SystemService>(),
    groupRepository: getIt<GroupRepository>(),
    groupMgmtHandler: getIt<GroupManagementHandler>(),
  ));

  getIt.registerFactory<ChatViewModel>(() => ChatViewModel(
    meshRepository: getIt<MeshRepository>(),
    messageRepository: getIt<MessageRepository>(),
    peerRepository: getIt<PeerRepository>(),
    signingService: getIt<SigningService>(),
  ));

  getIt.registerFactory<GameViewModel>(() => GameViewModel(
    gameHandler: getIt<GameHandler>(),
    gameRepository: getIt<GameRepository>(),
    signingService: getIt<SigningService>(),
  ));

  getIt.registerFactory<GroupChatViewModel>(() => GroupChatViewModel(
    meshRepository: getIt<MeshRepository>(),
    messageRepository: getIt<MessageRepository>(),
    groupRepository: getIt<GroupRepository>(),
    peerRepository: getIt<PeerRepository>(),
    signingService: getIt<SigningService>(),
    groupMgmtHandler: getIt<GroupManagementHandler>(),
  ));
}

class MyApp extends StatelessWidget {
  final String? initError;

  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyMesh',
      navigatorKey: navigatorKey,
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
