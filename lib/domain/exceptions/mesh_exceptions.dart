/// Base exception for all mesh networking errors.
sealed class MeshException implements Exception {
  final String message;
  final Object? cause;

  const MeshException(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';
}

/// ECDH derivation failed, no shared secret available for peer.
class EncryptionException extends MeshException {
  const EncryptionException(super.message, [super.cause]);
}

/// Send failed, endpoint unreachable.
class ConnectionException extends MeshException {
  const ConnectionException(super.message, [super.cause]);
}

/// Invalid Ed25519 signature on received packet.
class SignatureException extends MeshException {
  const SignatureException(super.message, [super.cause]);
}

/// Malformed JSON, missing fields in wire protocol.
class PacketFormatException extends MeshException {
  const PacketFormatException(super.message, [super.cause]);
}

/// Peer not found in database.
class PeerNotFoundException extends MeshException {
  const PeerNotFoundException(super.message, [super.cause]);
}
