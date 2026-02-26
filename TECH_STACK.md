# Tech Stack — Plane Messenger

Plane Messenger is an offline-first, peer-to-peer mesh messaging app for Android. It requires no internet connection and no central server. Devices communicate directly with each other over Bluetooth and Wi-Fi using a flooding mesh topology.

---

## Language & Framework

| Technology | Version | Purpose |
|---|---|---|
| **Dart** | 3.x | Primary programming language |
| **Flutter** | 3.x | Cross-platform UI framework; currently targeting Android |

Flutter provides the widget tree, Material Design 3 theming, and the reactive `StreamBuilder` pattern used throughout the UI.

---

## P2P Networking

### `nearby_connections` ^4.3.0
The core transport layer. Wraps Google's **Nearby Connections API**, which multiplexes over Bluetooth Classic, Bluetooth LE, and Wi-Fi Direct without requiring an internet connection or any pairing step.

- **Strategy:** `P2P_CLUSTER` — each device simultaneously advertises and discovers, forming a decentralised mesh. Only devices advertising the same `serviceId` (`com.plane.messenger`) are visible; random Bluetooth peripherals are ignored by the API.
- **Role in app:** `ConnectionManager` (`lib/data/datasources/p2p/connection_manager.dart`) wraps all Nearby Connections calls, exposing clean callbacks for connection lifecycle and payload receipt.
- **Mesh routing:** `MeshRepositoryImpl` (`lib/data/repositories/mesh_repository_impl.dart`) implements TTL-based flooding: each broadcast message is relayed by every receiving peer until its TTL reaches zero, ensuring it reaches devices that are not directly adjacent.

#### Bidirectional connection handshake

Every connection is a **single, symmetric channel** established through mutual acceptance:

```
Device A (Discoverer)                  Device B (Advertiser)
──────────────────────────────────────────────────────────────
startDiscovery() finds B
requestConnection(B) ─────────────────►
                       onConnectionInitiated fires on BOTH A and B
acceptConnection(B) ◄──────────────── acceptConnection(A)
                       onConnectionResult(CONNECTED) fires on BOTH
◄──────────── bidirectional data flow ────────────►
```

Key rules implemented in `ConnectionManager`:
1. **Both sides must accept.** `onConnectionInitiated` fires on the discoverer (via the `requestConnection` callback) AND on the advertiser (via the `startAdvertising` callback). Both call `acceptConnection`, which registers the payload receiver and unblocks the link.
2. **Unified handlers.** `startAdvertising` and `requestConnection` share the same private `_handleConnectionInitiated`, `_handleConnectionResult`, and `_handleDisconnected` methods so both code paths behave identically.
3. **`onConnectionResult(CONNECTED)` fires on both sides** once mutual acceptance is confirmed. Only then does `MeshRepositoryImpl.onConnectionEstablished` run and the Ed25519 handshake packet is sent.

---

## Local Persistence

### `isar` 3.1.0+1 + `isar_flutter_libs` 3.1.0+1
**Isar** is an embedded, reactive NoSQL database written in Rust and compiled to native libraries. It is used to persist all messages and discovered peers across app restarts.

- **`MessageEntity`** — stores each mesh message (ID, sender, payload, timestamp, signature, TTL, ownership flag).
- **`PeerEntity`** — stores each discovered peer (device ID, public key, connection status, last-seen timestamp, optional nickname).
- Isar's `watch()` streams feed `StreamBuilder` widgets directly, so the UI updates in real-time as new messages or peers arrive.

### `isar_generator` 3.1.0+1 + `build_runner` ^2.4.13 *(dev)*
Code-generation tools that produce the `*.g.dart` schema files from the annotated entity classes. Run with:
```
dart run build_runner build
```

### `path_provider` ^2.0.0
Resolves the platform-appropriate application documents directory so Isar knows where to create its database file.

---

## Cryptography

### `cryptography` ^2.6.1
Provides the **Ed25519** digital signature algorithm.

- On first launch, `KeyManager` (`lib/core/security/key_manager.dart`) generates an Ed25519 key pair for the device.
- Every outgoing message's data section is signed with the device's private key.
- Every incoming message's signature is verified against the claimed sender's public key before the message is accepted or relayed. This prevents message forgery across the mesh.

### `flutter_secure_storage` ^9.0.0
Stores the Ed25519 private key bytes (Base64-encoded) in the platform's secure keystore (Android Keystore on Android). The key survives app restarts and is never written to regular storage.

---

## Dependency Injection

### `get_it` ^9.2.0
A lightweight **service locator**. All long-lived singletons (`IsarService`, `KeyManager`, `ConnectionManager`, `MeshRepositoryImpl`) are registered in `main.dart` and accessed anywhere in the app via `getIt<T>()`.

---

## State Management

### `flutter_bloc` ^9.1.1
The BLoC (Business Logic Component) package is included as a dependency and is ready for use. The current MVP accesses services directly via `get_it` in the pages, but BLoC is the intended state-management pattern for future feature growth.

### `equatable` ^2.0.8
Provides value-equality comparison for Dart objects without boilerplate. Used alongside BLoC state/event classes to make equality checks efficient.

---

## Utilities

### `uuid` ^4.5.2
Generates **UUID v4** strings used as unique message IDs. These IDs are included in every packet and tracked in-memory to prevent the mesh flooding from relaying the same message twice (deduplication).

### `permission_handler` ^12.0.1
Handles runtime permission requests on Android (Location, Bluetooth Advertise/Connect/Scan, Nearby Wi-Fi Devices). The Nearby Connections API requires all of these to be granted before advertising or discovery can start.

---

## Dev / Tooling

| Package | Purpose |
|---|---|
| `flutter_lints` ^5.0.0 | Enforces Flutter's recommended lint rules via `analysis_options.yaml` |
| `flutter_test` | Widget and unit testing SDK (bundled with Flutter) |

---

## Architecture Overview

```
lib/
├── core/
│   └── security/
│       ├── key_manager.dart        # Ed25519 + X25519 key generation, signing, ECDH
│       └── crypto_service.dart     # AES-256-GCM encrypt/decrypt, shared secret cache
├── data/
│   ├── models/
│   │   ├── message_entity.dart     # Isar collection: mesh messages
│   │   └── peer_entity.dart        # Isar collection: discovered peers
│   ├── datasources/
│   │   ├── local/
│   │   │   └── isar_service.dart   # Database read/write/watch helpers
│   │   └── p2p/
│   │       └── connection_manager.dart  # Nearby Connections wrapper
│   └── repositories/
│       └── mesh_repository_impl.dart   # Mesh routing, packet handling
└── presentation/
    └── pages/
        ├── radar_page.dart         # Peer discovery grid
        ├── chat_page.dart          # Message list + send input
        └── error_page.dart         # Initialization failure UI
```

The app follows a layered architecture: the **presentation** layer observes reactive streams from the **data** layer; the **core** layer provides cross-cutting concerns (cryptography). There is no network layer — all communication is local and P2P.

---

## End-to-End Encryption (E2EE)

Direct messages between two peers are encrypted end-to-end. Relay nodes forward encrypted packets based on routing metadata but cannot read the payload. Broadcast messages remain plaintext.

### Key Exchange — X25519 ECDH

Each device generates a persistent **X25519** key pair alongside its Ed25519 identity key pair (both managed by `KeyManager`). During the Nearby Connections handshake, peers exchange both their Ed25519 and X25519 public keys:

```json
{
  "type": "handshake",
  "pubKey": "<base64-ed25519-public-key>",
  "x25519PubKey": "<base64-x25519-public-key>",
  "nickname": "optional"
}
```

`CryptoService` uses the local X25519 private key and the remote peer's X25519 public key to derive a **shared secret** via Elliptic Curve Diffie-Hellman. The shared secret is cached in memory (keyed by the peer's Ed25519 identity key) for the lifetime of the process.

### Symmetric Encryption — AES-256-GCM

Message payloads are encrypted with **AES-256-GCM** using the ECDH-derived shared secret. Each message uses a unique random 12-byte nonce. The cipher produces authenticated ciphertext and a 16-byte MAC tag.

### Encrypted Packet Wire Format

```json
{
  "t": { "ttl": 3, "target": "<recipient-ed25519-pubkey>" },
  "d": {
    "id": "<uuid>",
    "sender": "<sender-ed25519-pubkey>",
    "ts": "<epoch-ms>",
    "payload": "<base64-ciphertext>",
    "nonce": "<base64-12-byte-nonce>",
    "mac": "<base64-16-byte-mac>",
    "enc": true
  },
  "s": "<base64-ed25519-signature-of-d>"
}
```

Key design decisions:

- **`enc: true`** distinguishes encrypted DMs from plaintext broadcasts. Absence or `false` means plaintext.
- **`t.target`** is set to the recipient's Ed25519 public key for routing. Relay nodes inspect this field to determine where to forward but cannot decrypt the payload.
- **Signature covers `d`** in its encrypted form, so relay nodes can verify authenticity without decrypting.
- **Relay policy**: all messages with `ttl > 0` are relayed (both broadcasts and DMs), ensuring DMs reach non-adjacent peers through the mesh.

### Trust Model

- **Authentication**: Ed25519 signatures on every message prevent forgery.
- **Confidentiality**: AES-256-GCM with ECDH-derived keys ensures only the sender and recipient can read DM content.
- **Relay transparency**: intermediate nodes see `target`, `sender`, `ttl`, and `timestamp` but the payload is opaque ciphertext.
- **No forward secrecy** (current): static X25519 keys mean the shared secret is deterministic. The `CryptoService` interface is designed so ephemeral per-session keys can be added without changing callers.

### Architecture

```
┌─────────────┐     derives shared secret     ┌──────────────┐
│  KeyManager  │──────────────────────────────►│ CryptoService│
│ (Ed25519 +   │                               │ (AES-256-GCM │
│  X25519 keys)│                               │  + cache)    │
└─────────────┘                               └──────┬───────┘
                                                      │
                                                      ▼
                                            ┌──────────────────┐
                                            │MeshRepositoryImpl│
                                            │ sendDirectMessage│
                                            │ broadcastMessage │
                                            └──────────────────┘
```

`KeyManager` owns key lifecycle (generation, storage, ECDH derivation). `CryptoService` owns encryption operations and the shared-secret cache. `MeshRepositoryImpl` orchestrates packet construction, signing, encryption, and relay — delegating crypto to the dedicated services.
