# Plane Messenger

Offline-first, peer-to-peer mesh messenger for Android. No servers. No accounts. No internet.

---

## Overview

Plane Messenger lets two phones in the same room talk to each other without any infrastructure in between. Devices discover one another over Bluetooth and Wi-Fi Direct, then relay signed, end-to-end encrypted messages across a flooding mesh. If a friend is out of radio range, other nearby devices forward the traffic until it lands.

The project explores what an honest, fully decentralized messenger looks like when you remove the cloud entirely — including the trade-offs around discovery, key management, store-and-forward delivery, and UX for an unreliable transport.

## Features

**Messaging**
- One-to-one chats with end-to-end encryption (X25519 ECDH + AES-256-GCM)
- Group chats with invite, kick, leave, and automatic creator succession
- Broadcasts to every reachable device on the mesh
- Automatic retry of failed sends when the peer comes back into range
- Nickname propagation to anyone you connect to

**Mesh transport**
- Flooding with a 3-hop TTL and a 500-entry deduplication cache
- Foreground service keeps the radio alive and shows the live peer count
- Local notifications for messages, game invites, and group invites — suppressed when the relevant screen is already open

**Built-in games**
- Tic Tac Toe on a 3x3 grid
- Color Memory — best-of-three rounds judged by CIEDE2000 perceptual color distance
- Battleship — 10x10 grid with hit, miss, and sunk detection
- All games run over the same encrypted channel with ACKs and retransmits

## Tech stack

| Layer | Tooling |
|---|---|
| UI | Flutter (Material 3), `StatefulWidget` + `StreamBuilder` |
| Language | Dart 3 (sealed classes, pattern matching, records) |
| P2P transport | `nearby_connections` (Bluetooth + Wi-Fi Direct via Google's Nearby Connections API) |
| Persistence | Isar 3 (reactive NoSQL with watch streams) |
| Crypto | `cryptography` — Ed25519 signatures, X25519 ECDH, AES-256-GCM |
| Key storage | `flutter_secure_storage` (Android Keystore) |
| DI | `get_it` (two-phase: storage/crypto → mesh layer post-permissions) |
| Background | `flutter_foreground_task` |
| Notifications | `flutter_local_notifications` (per-type channels) |
| Permissions | `permission_handler` (BT, location, nearby Wi-Fi) |
| Misc | `flutter_colorpicker` (hue ring), `uuid` v4 |

## Architecture

Clean four-layer structure under `lib/`:

```
core/          KeyManager, CryptoService, secure storage, prefs
domain/        Repository & service interfaces, sealed exceptions
data/          Isar entities, Nearby Connections wrapper, handlers,
               MeshRepositoryImpl (central packet dispatcher)
presentation/  Pages, ViewModels, Widgets
```

`MeshRepositoryImpl` dispatches inbound packets to specialized handlers:

- `HandshakeHandler` — key exchange, nickname sync, self-connection detection
- `MessageRouter` — verify, dedup, decrypt, persist, relay
- `GameHandler` — invites, moves, ACKs for all three games (direct P2P, never flooded)
- `GroupManagementHandler` — group CRUD, flooded with its own dedup cache
- `PacketCodec` — Ed25519 sign/verify of the wire envelope

## Getting started

**Requirements:** Flutter 3.x, Dart 3.9+, a physical Android device (the Nearby Connections API does not work on emulators).

```bash
flutter pub get              # install dependencies
flutter run                  # run on a connected Android device
flutter analyze              # static analysis
flutter test                 # run all unit tests
flutter build apk            # build a release APK
```

After modifying any Isar `@collection` entity, regenerate the schema:

```bash
dart run build_runner build
```

The first launch walks through a permission preflight (Bluetooth advertise/connect/scan, location, nearby Wi-Fi) before the mesh layer is initialized.

## Project structure

```
plane_messenger/
├── lib/
│   ├── core/           cross-cutting concerns (crypto, storage)
│   ├── domain/         abstractions (repositories, services, errors)
│   ├── data/           implementations (DB, transport, handlers)
│   └── presentation/   pages, view models, widgets
├── test/               unit tests
├── android/            Android-specific config and manifests
└── pubspec.yaml
```
