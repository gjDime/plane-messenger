
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

class ConnectionManager {
  final Strategy strategy = Strategy.P2P_CLUSTER;

  // Short human-readable identifier for this device in the Nearby Connections API
  final String userName;

  // Callbacks for connection lifecycle and payload events
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

  Future<bool> startAdvertising() async {
    try {
      return await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: (id, info) => onConnectionInitiated(id, info),
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            onConnectionResult(id);
          } else {
            debugPrint('[P2P] Connection to $id failed with status: $status');
          }
        },
        onDisconnected: (id) => onDisconnected(id),
        serviceId: 'com.plane.messenger',
      );
    } catch (e) {
      debugPrint('[P2P] Error starting advertising: $e');
      return false;
    }
  }

  Future<bool> startDiscovery() async {
    try {
      return await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // Auto-connect to form mesh; identity is verified via Ed25519 handshake
          requestConnection(id, name);
        },
        onEndpointLost: (id) {
          debugPrint('[P2P] Endpoint lost: $id');
        },
        serviceId: 'com.plane.messenger',
      );
    } catch (e) {
      debugPrint('[P2P] Error starting discovery: $e');
      return false;
    }
  }

  Future<void> stopAdvertising() async {
    await Nearby().stopAdvertising();
  }

  Future<void> stopDiscovery() async {
    await Nearby().stopDiscovery();
  }

  Future<void> requestConnection(String endpointId, String name) async {
    try {
      await Nearby().requestConnection(
        userName,
        endpointId,
        onConnectionInitiated: (id, info) => onConnectionInitiated(id, info),
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            onConnectionResult(id);
          }
        },
        onDisconnected: (id) => onDisconnected(id),
      );
    } catch (e) {
      debugPrint('[P2P] Error requesting connection to $endpointId: $e');
    }
  }

  Future<void> acceptConnection(String endpointId) async {
    await Nearby().acceptConnection(
      endpointId,
      // Note: 'onPayLoadRecieved' is a typo in the nearby_connections library API
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
