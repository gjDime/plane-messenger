
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

  final void Function(String endpointId, ConnectionInfo info) onConnectionInitiated;
  final void Function(String endpointId) onConnectionResult;
  final void Function(String endpointId) onDisconnected;
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

  void _handleConnectionInitiated(String id, ConnectionInfo info) {
    onConnectionInitiated(id, info);
  }

  void _handleConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      onConnectionResult(id);
    } else {
      debugPrint('[P2P] Connection to $id failed: $status');
    }
  }

  void _handleDisconnected(String id) {
    onDisconnected(id);
  }

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

  /// Endpoint IDs with an active connection. Discovery skips these to avoid
  /// `STATUS_ALREADY_CONNECTED_TO_ENDPOINT` errors after a refresh.
  final Set<String> _connectedEndpoints = {};

  void markConnected(String endpointId) => _connectedEndpoints.add(endpointId);
  void markDisconnected(String endpointId) =>
      _connectedEndpoints.remove(endpointId);

  Future<bool> startDiscovery() async {
    try {
      return await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (!_connectedEndpoints.contains(id)) {
            requestConnection(id, name);
          }
        },
        onEndpointLost: (id) {},
        serviceId: _serviceId,
      );
    } catch (e) {
      debugPrint('[P2P] Error starting discovery: $e');
      return false;
    }
  }

  Future<void> stopAdvertising() async => Nearby().stopAdvertising();

  Future<void> stopDiscovery() async => Nearby().stopDiscovery();

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

  Future<void> sendPayload(String endpointId, Uint8List bytes) async {
    await Nearby().sendBytesPayload(endpointId, bytes);
  }

  Future<void> disconnectFromEndpoint(String endpointId) async {
    await Nearby().disconnectFromEndpoint(endpointId);
  }
}
