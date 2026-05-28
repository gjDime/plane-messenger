import 'dart:typed_data';

/// Callback interface for connection lifecycle events.
abstract interface class P2PConnectionObserver {
  void onConnectionEstablished(String endpointId);
  void onPeerDisconnected(String endpointId);
  void onPayloadReceived(String endpointId, Uint8List bytes);
}

/// Wraps the platform P2P connectivity layer (e.g. Google Nearby Connections).
abstract interface class P2PConnectionService {
  Set<String> get connectedEndpoints;
  Future<bool> startAdvertising();
  Future<bool> startDiscovery();
  Future<void> stopAdvertising();
  Future<void> stopDiscovery();
  Future<void> requestConnection(String endpointId, String name);
  Future<void> acceptConnection(String endpointId);
  Future<void> sendPayload(String endpointId, Uint8List bytes);
  Future<void> disconnectFromEndpoint(String endpointId);
}
