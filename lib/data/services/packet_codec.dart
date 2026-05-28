import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

class PacketCodec {
  final SigningService _signingService;

  const PacketCodec(this._signingService);

  Future<Uint8List> signAndEncode(
    Map<String, dynamic> dataMap, {
    required Map<String, dynamic> transport,
  }) async {
    final dataJson = jsonEncode(dataMap);
    final dataBytes = utf8.encode(dataJson);
    final signatureBytes = await _signingService.sign(dataBytes);
    final signature = base64Encode(signatureBytes);

    final packetMap = {'t': transport, 'd': dataMap, 's': signature};
    return Uint8List.fromList(utf8.encode(jsonEncode(packetMap)));
  }

  Future<bool> verifySignature(
    Map<String, dynamic> data,
    String signatureBase64,
    String senderKeyBase64,
  ) async {
    final dataJson = jsonEncode(data);
    final dataBytes = utf8.encode(dataJson);

    late List<int> signatureBytes;
    late List<int> senderKeyBytes;
    try {
      signatureBytes = base64Decode(signatureBase64);
      senderKeyBytes = base64Decode(senderKeyBase64);
    } catch (e) {
      debugPrint('[MESH] Invalid base64 in signature or sender key: $e');
      return false;
    }

    return _signingService.verify(dataBytes, signatureBytes, senderKeyBytes);
  }
}
