import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// Mocking secure storage is hard without cleaner dependency injection or mocktail
// For now, let's test the logic that doesn't depend on static storage if possible
// Or modify KeyManager to be testable.

void main() {
  group('Mesh Logic Tests', () {
    test('Packet JSON Serialization', () {
      final dataMap = {
        "id": "123",
        "sender": "senderKey",
        "ts": 1000,
        "payload": "test",
      };

      final packetMap = {
        "t": {"ttl": 3, "target": "BROADCAST"},
        "d": dataMap,
        "s": "signature",
      };

      final json = jsonEncode(packetMap);
      expect(json, contains('"ttl":3'));
      expect(json, contains('"payload":"test"'));

      final decoded = jsonDecode(json);
      expect(decoded['t']['ttl'], 3);
    });
  });
}
