
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

/// Wraps Google's Nearby Connections API and exposes a clean, callback-based
/// interface for the mesh networking layer.
///
/// ## Connection handshake (bidirectional)
///
/// ```
/// Device A (Discoverer)              Device B (Advertiser)
/// ───────────────────────────────────────────────────────
/// startDiscovery() finds B
/// requestConnection(B) ──────────────►
///                          onConnectionInitiated fires on BOTH A and B
/// acceptConnection(B) ◄──────────── acceptConnection(A)
///                          onConnectionResult(CONNECTED) fires on BOTH
/// ◄──── bidirectional data flow ────►
/// ```
///
/// Both [startAdvertising] and [requestConnection] register the same private
/// handlers ([_handleConnectionInitiated], [_handleConnectionResult],
/// [_handleDisconnected]) so every connection — regardless of which side
/// initiated it — goes through an identical code path.
class ConnectionManager {
  static const _serviceId = 'com.plane.messenger';

  final Strategy strategy = Strategy.P2P_CLUSTER;

  /// Short identifier advertised to nearby devices (nickname or key prefix).
  final String userName;

  // ── Callbacks injected by the mesh layer ──────────────────────────────────

  /// Called on BOTH the initiating and accepting side when a connection is
  /// being negotiated. The receiver should call [acceptConnection] here.
  final void Function(String endpointId, ConnectionInfo info) onConnectionInitiated;

  /// Called on BOTH sides once the connection is fully established and data
  /// can flow in both directions.
  final void Function(String endpointId) onConnectionResult;

  /// Called on BOTH sides when a connection is lost.
  final void Function(String endpointId) onDisconnected;

  /// Called whenever a BYTES payload is received from a connected peer.
  final void Function(String endpointId, Uint8List payload) onPayloadReceived;

  ConnectionManager({
    required String userName,
    required this.onConnectionInitiated,
    required this.onConnectionResult,
    required this.onDisconnected,
    required this.onPayloadReceived,
  }) : userName = userName.trim() {
    assert(userName.trim().isNotEmpty, 'userName must not be empty');
  }

  // ── Lifecycle handlers (shared by advertising and discovery paths) ─────────

  void _handleConnectionInitiated(String id, ConnectionInfo info) {
    debugPrint('[P2P] Connection initiated with $id (${info.endpointName})');
    onConnectionInitiated(id, info);
  }

  void _handleConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      debugPrint('[P2P] Connection established with $id');
      onConnectionResult(id);
    } else {
      debugPrint('[P2P] Connection to $id failed: $status');
    }
  }

  void _handleDisconnected(String id) {
    debugPrint('[P2P] Disconnected from $id');
    onDisconnected(id);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Starts advertising this device so nearby discoverers can find it.
  /// [_handleConnectionInitiated] fires when a discoverer requests a
  /// connection; the caller should respond with [acceptConnection].
  Future<bool> startAdvertising() async {
    try {
      return await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
        serviceId: _serviceId,
      );
    } catch (e) {
      debugPrint('[P2P] Error starting advertising: $e');
      return false;
    }
  }

  /// Starts scanning for nearby advertisers. When an endpoint is found,
  /// [requestConnection] is called automatically to form the mesh.
  Future<bool> startDiscovery() async {
    try {
      return await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // Auto-connect; identity is verified via Ed25519 handshake after
          // the Nearby Connections session is established.
          requestConnection(id, name);
        },
        onEndpointLost: (id) {
          debugPrint('[P2P] Endpoint lost: $id');
        },
        serviceId: _serviceId,
      );
    } catch (e) {
      debugPrint('[P2P] Error starting discovery: $e');
      return false;
    }
  }

  Future<void> stopAdvertising() async => Nearby().stopAdvertising();

  Future<void> stopDiscovery() async => Nearby().stopDiscovery();

  /// Initiates a connection to [endpointId]. Uses the same lifecycle handlers
  /// as [startAdvertising] so both sides of every connection are treated
  /// identically — the mutual acceptance that makes the link bidirectional.
  Future<void> requestConnection(String endpointId, String name) async {
    try {
      await Nearby().requestConnection(
        userName,
        endpointId,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
      );
    } catch (e) {
      debugPrint('[P2P] Error requesting connection to $endpointId: $e');
    }
  }

  /// Accepts a pending connection and registers the payload receiver.
  /// Must be called by BOTH sides in response to [onConnectionInitiated]
  /// before data can flow.
  Future<void> acceptConnection(String endpointId) async {
    await Nearby().acceptConnection(
      endpointId,
      // Note: 'onPayLoadRecieved' is a typo in the nearby_connections library API.
      onPayLoadRecieved: (id, payload) {
        if (payload.type == PayloadType.BYTES) {
          final bytes = payload.bytes;
          if (bytes != null) {
            onPayloadReceived(id, bytes);
          } else {
            debugPrint('[P2P] Received BYTES payload with null data from $id');
          }
        }
      },
    );
  }

  /// Sends raw bytes to a connected peer. Throws if the peer is not connected.
  Future<void> sendPayload(String endpointId, Uint8List bytes) async {
    await Nearby().sendBytesPayload(endpointId, bytes);
  }

  Future<void> disconnectFromEndpoint(String endpointId) async {
    await Nearby().disconnectFromEndpoint(endpointId);
  }
}
