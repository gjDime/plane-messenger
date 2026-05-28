import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/domain/repositories/mesh_repository.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

class ChatViewModel {
  final MeshRepository _meshRepository;
  final MessageRepository _messageRepository;
  final PeerRepository _peerRepository;
  final SigningService _signingService;

  String? _myPublicKey;

  ChatViewModel({
    required MeshRepository meshRepository,
    required MessageRepository messageRepository,
    required PeerRepository peerRepository,
    required SigningService signingService,
  })  : _meshRepository = meshRepository,
        _messageRepository = messageRepository,
        _peerRepository = peerRepository,
        _signingService = signingService;

  String? get myPublicKey => _myPublicKey;

  Future<void> init(PeerEntity peer) async {
    _myPublicKey = await _signingService.publicKeyBase64;
    await _peerRepository.markPeerAsRead(peer.deviceId);
  }

  Stream<List<MessageEntity>> watchMessages(PeerEntity peer) {
    if (peer.publicKey.isNotEmpty && _myPublicKey != null) {
      return _messageRepository.watchMessagesForPeer(peer.publicKey, _myPublicKey!);
    }
    return _messageRepository.watchMessages();
  }

  Future<void> sendMessage(PeerEntity peer, String text) async {
    if (peer.publicKey.isNotEmpty) {
      await _meshRepository.sendDirectMessage(peer.publicKey, text);
    } else {
      await _meshRepository.broadcastMessage(text);
    }
  }

  Future<void> resendMessage(MessageEntity msg) =>
      _meshRepository.resendFailedMessage(msg);
}
