# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SkyMesh** (package name: `plane_messenger`) is an offline-first, peer-to-peer mesh messaging Android app. No internet or central server required — devices communicate over Bluetooth and Wi-Fi Direct using Google's Nearby Connections API with a flooding mesh topology. Messages are signed with Ed25519 and direct messages are encrypted end-to-end with AES-256-GCM (X25519 ECDH key exchange).

The Flutter project root is `plane_messenger/`, not the repo root. All commands must be run from there.

## Build & Development Commands

```bash
cd plane_messenger

flutter pub get              # Install dependencies
flutter run                  # Run on connected Android device (primary target)
flutter analyze              # Static analysis / linting
flutter test                 # Run all tests
flutter test test/mesh_test.dart  # Run a single test file
dart run build_runner build  # Regenerate Isar *.g.dart schema files
flutter clean                # Clean build artifacts
flutter build apk            # Build release APK
```

**After changing any Isar `@collection` entity** (`MessageEntity`, `PeerEntity`, `GameSessionEntity`, `GameMoveEntity`, `GroupEntity`), you must run `dart run build_runner build` and commit the regenerated `*.g.dart` files. New schemas must also be added to the `Isar.open()` call in `isar_database.dart`.

## Architecture

Four-layer structure under `plane_messenger/lib/`:

- **`core/`** — Cross-cutting concerns: `KeyManager` (Ed25519 + X25519 key lifecycle), `CryptoService` (AES-256-GCM encrypt/decrypt + ECDH shared-secret cache), `FlutterSecureStorageService` (platform keystore wrapper implementing `SecureStorageService`), `UserPrefs` (nickname storage)
- **`domain/`** — Abstractions only. Repository interfaces (`PeerRepository`, `MessageRepository`, `MeshRepository`, `GameRepository`, `GroupRepository`), service interfaces (`SigningService`, `EncryptionService`, `P2PConnectionService`, `SecureStorageService`, `SystemService`), and a sealed exception hierarchy in `mesh_exceptions.dart` (`MeshException` base with `EncryptionException`, `ConnectionException`, `SignatureException`, `PacketFormatException`, `PeerNotFoundException`).
- **`data/`** — Concrete implementations. Models (Isar `@collection` entities), datasources (`IsarDatabase` for DB, `ConnectionManager` for Nearby Connections API, `AndroidSystemService` for platform services), services (handler classes, `PacketCodec` for wire-format signing/verification), and `MeshRepositoryImpl` (central mesh orchestrator).
- **`presentation/`** — UI layer. Pages (`RadarPage`, `ChatPage`, `GamePage`, `ColorMemoryPage`, `GroupChatPage`, `CreateGroupPage`, `PreflightPage`, `ErrorPage`), ViewModels (`RadarViewModel`, `ChatViewModel`, `GameViewModel`, `GroupChatViewModel`), and Widgets (`GameSelectionDialog`, `HsbSliderPicker`). Uses `StatefulWidget` + `StreamBuilder` with Isar watch streams.

### Handler Pattern

`MeshRepositoryImpl` is the central packet dispatcher. It constructs specialized handlers in its constructor and exposes them as getters for DI registration:

- **`HandshakeHandler`** — Connection handshake, key exchange, nickname sync, self-connection detection (compares Ed25519 public keys and disconnects)
- **`MessageRouter`** — Inbound message verification, dedup (seen-ID cache of 500), decryption, storage, relay
- **`PacketCodec`** — Ed25519 signing (`signAndEncode`) and signature verification (`verifySignature`). Used by `MeshRepositoryImpl`, `MessageRouter`, and `GameHandler`.
- **`GameHandler`** — Multi-game P2P lifecycle (invites, moves, ACKs). Supports Tic-Tac-Toe and Color Memory via game-type routing in `handleGameMovePacket`. Uses `_sendEncryptedGamePayload` shared helper for all encrypted outbound payloads. Direct P2P payloads, never flooded.
- **`GroupManagementHandler`** — Group CRUD (create, invite, accept/decline, kick, leave). Flooded with TTL, separate dedup cache (200 entries).

To add a new packet type: add a dispatch case in `MeshRepositoryImpl.onPayloadReceived`, create a handler class, construct it in the `MeshRepositoryImpl` constructor, expose it as a getter, and register it in `main.dart`.

To add a new game type: add game-type-specific logic in `GameHandler` (`sendInvite` board init, `handleGameMovePacket` routing, outbound methods), create a pure logic class (like `TicTacToeLogic` / `ColorMemoryLogic`), add a page, and wire navigation in `ChatPage`/`GameSelectionDialog`. The invite/accept/decline/abandon lifecycle and `_sendEncryptedGamePayload` helper are shared across all game types.

### DI Registration (two-phase)

**Phase 1** (`main()`) — No permissions needed: `SecureStorageService` → `UserPrefs` → `SystemService` → `IsarDatabase` → repositories (`PeerRepository`, `MessageRepository`, `GameRepository`, `GroupRepository`) → `KeyManager` (as `SigningService`) → `CryptoService` (as `EncryptionService`)

**Phase 2** (`initializeMesh()`, called by `PreflightPage` after permissions granted) — `ConnectionManager` (as `P2PConnectionService`) → `MeshRepositoryImpl` (as `MeshRepository`, constructs all handlers internally) → extract `GameHandler` and `GroupManagementHandler` → ViewModels (`RadarViewModel`, `ChatViewModel`, `GameViewModel`, `GroupChatViewModel` as factories)

Access via `getIt<T>()`. Handlers are built inside `MeshRepositoryImpl` but registered separately in `getIt` so ViewModels can depend on them directly.

### Wire Protocol

JSON over Nearby Connections BYTES payloads. Dispatch logic in `MeshRepositoryImpl.onPayloadReceived`:

Packets with `"d"` key (mesh data envelope `{t,d,s}`):

| Condition | Handler | Routing |
|---|---|---|
| `d` contains `gameId` | `GameHandler.handleGameMovePacket` (routes to `_handleTicTacToePayload` or `_handleColorMemoryPayload` based on session's `gameType`) | Direct P2P |
| `d` has target `"group:<uuid>"` | `MessageRouter` | Flooded (TTL-based, membership gate) |
| Other | `MessageRouter` | Flooded (TTL-based, dedup via seen-ID cache of 500) |

Packets without `"d"` key (dispatched by `type` field):

| Type | Handler | Routing |
|---|---|---|
| `handshake` | `HandshakeHandler.handleHandshake` | Direct P2P |
| `nickname_update` | `HandshakeHandler.handleNicknameUpdate` | Direct P2P |
| `group_management` | `GroupManagementHandler.handlePacket` | Flooded (TTL-based, dedup via separate cache of 200) |
| `game_invite`, `game_accept`, `game_decline`, `game_move_ack`, `game_abandon` | `GameHandler.handleGamePacket` | Direct P2P |

### Group Messages vs Group Management

- **Group management** packets (`type: "group_management"`) handle create/invite/kick/leave — flooded with their own dedup set (`_seenGroupMgmtIds`, max 200).
- **Group messages** use the standard `{t,d,s}` mesh envelope with `target: "group:<uuid>"`. `MessageRouter` applies a membership gate: only saves if `isMember && timestamp >= joinedAt`. Always relayed regardless of membership.
- Group messages are plaintext (no E2EE). Direct messages use AES-256-GCM encryption.

### Color Memory Game

Best-of-3 rounds P2P game. Each round: dealer generates a random color, both players see it for 5 seconds, then both guess using a color picker. Closer guess (CIEDE2000 perceptual distance) wins the round. First to 2 round wins takes the match.

- **`ColorMemoryState`** (`lib/data/models/color_memory_state.dart`) — Type-safe model serialized to/from `GameSessionEntity.colorGameData` (not an Isar entity itself). Contains `currentRound`, `xRoundsWon`, `oRoundsWon`, and a list of `ColorMemoryRound` (targetColor, guesses, distances).
- **`ColorMemoryLogic`** (`lib/data/services/color_memory_logic.dart`) — Pure static utility: `generateRandomColor` (constrained HSV), `colorDistance` (full CIEDE2000), `scoreFromDistance`, `roundWinner`, `dealerIsPlayerX` (X deals rounds 1,3; O deals round 2).
- **Wire protocol**: Two move types within encrypted game payloads: `round_start` (dealer sends target color) and `color_guess` (player sends guess). Both use the shared `_sendEncryptedGamePayload` helper and ACK/retransmit system.
- **UI**: `ColorMemoryPage` with phases (showing color → guessing → results → game over). Two picker styles: `HsbSliderPicker` (custom) and `HueRingPicker` (from `flutter_colorpicker` package).
- **`GameSelectionDialog`** — ChatPage game icon opens this dialog to choose between Tic Tac Toe and Color Memory before sending an invite.

### Pending Invites Pattern

Both `GameHandler` and `GroupManagementHandler` expose a `Stream<PendingXxxInvite>` via a broadcast `StreamController`. UI subscribes in `initState` and shows a dialog. Invites are transient (not persisted to Isar).

### Radar Page Data Model

`RadarViewModel.watchRadarItems()` returns `Stream<List<RadarItem>>` combining peers and groups. `RadarItem` is a sealed class with `PeerRadarItem` and `GroupRadarItem` subtypes, pattern-matched in the UI.

## Key Constraints

- **Isar pinned to 3.1.0+1** across `isar`, `isar_flutter_libs`, and `isar_generator`. All three must stay in sync. The `android/build.gradle.kts` has a namespace workaround for AGP compatibility.
- **`nearby_connections` API typo**: The callback is `onPayLoadRecieved` (misspelled in the library). This is intentional, not a bug in our code.
- **Android permissions**: BT advertise/connect/scan, location (fine + coarse), nearby Wi-Fi. All required before Nearby Connections can start. Checked and requested by `PreflightPage` before mesh initialization.
- **Service ID**: `com.plane.messenger` — only devices with this exact service ID discover each other.
- **Game packets are never flooded** — they use direct `sendPayload` to the opponent's endpoint. Game moves are signed and encrypted with the existing ECDH shared secret. All game types share the same invite/accept/decline/abandon control packets; only move payloads differ per game type.
- **`flutter_colorpicker`** package — Used for the `HueRingPicker` widget in Color Memory. CIEDE2000 color distance is implemented manually (no external dependency).
- **Group creator succession** — When a group creator leaves, `memberPublicKeys[0]` becomes the new creator. If no members remain, the group is marked as empty.

## Testing Notes

- `test/mesh_test.dart` — Packet serialization
- `test/tictactoe_logic_test.dart` — Pure game logic (win detection, valid moves, draw)
- `test/color_memory_logic_test.dart` — CIEDE2000 distance, score curve, round winner, state serialization, color generation constraints
- `test/game_viewmodel_test.dart` — ViewModel helper logic (turn detection, player role, multi-game session creation)
- `test/group_logic_test.dart` — Group membership gate, dedup keys, succession, target ID format

`KeyManager` and `CryptoService` are hard to unit test due to `FlutterSecureStorage` static dependencies — would need DI refactoring or integration tests.
