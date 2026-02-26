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

**After changing `MessageEntity` or `PeerEntity`**, you must run `dart run build_runner build` and commit the regenerated `*.g.dart` files.

## Architecture

Three-layer structure under `plane_messenger/lib/`:

- **`core/`** — Cross-cutting: `KeyManager` (Ed25519 + X25519 key lifecycle), `CryptoService` (AES-256-GCM encrypt/decrypt + ECDH shared-secret cache), `UserPrefs` (nickname via flutter_secure_storage)
- **`data/`** — Models (Isar `@collection` entities), datasources (`IsarService` for DB, `ConnectionManager` for Nearby Connections API), and `MeshRepositoryImpl` (mesh routing, packet construction, signing, encryption, relay)
- **`presentation/`** — Flutter pages (`RadarPage`, `ChatPage`, `ErrorPage`). Currently uses `StatefulWidget` + `StreamBuilder` with Isar watch streams. `flutter_bloc` is a dependency but not yet used.

**DI**: `get_it` service locator. All singletons registered eagerly in `main()` in dependency order: `IsarService` → `KeyManager` → `CryptoService` → `ConnectionManager` → `MeshRepositoryImpl`. Access via `getIt<T>()`.

**Reactive data**: `IsarService` exposes `watch*()` streams that feed `StreamBuilder` widgets directly.

## Key Constraints

- **Isar pinned to 3.1.0+1** across `isar`, `isar_flutter_libs`, and `isar_generator`. All three must stay in sync. The `android/build.gradle.kts` has a namespace workaround for AGP compatibility.
- **`nearby_connections` API typo**: The callback is `onPayLoadRecieved` (misspelled in the library). This is intentional, not a bug in our code.
- **Android permissions**: BT advertise/connect/scan, location (fine + coarse), nearby Wi-Fi. All required before Nearby Connections can start. Handled at app init in `main.dart`.
- **Service ID**: `com.plane.messenger` — only devices with this exact service ID discover each other.
- **Wire protocol**: JSON over Nearby Connections BYTES payloads. Three packet types: `handshake`, `nickname_update`, and mesh message (identified by presence of `"d"` key). Relay uses TTL-based flooding (max TTL=3, seen-ID dedup cache of 500).
- **Self-connection detection**: P2P_CLUSTER mode can discover the device's own advertisement. `MeshRepositoryImpl._handleHandshake` detects this by comparing Ed25519 public keys and disconnects.

## Testing Notes

Tests are minimal. `test/mesh_test.dart` covers packet serialization. `KeyManager` and `CryptoService` are hard to unit test due to `FlutterSecureStorage` static dependencies — would need DI refactoring or integration tests.
