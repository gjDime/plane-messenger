/// Tracks which chat screen is currently visible so notifications can be
/// suppressed when the user is already viewing that conversation.
class ActiveScreenTracker {
  String? _activeDirectChatKey;
  String? _activeGroupChatId;

  void enterDirectChat(String peerPublicKey) {
    _activeDirectChatKey = peerPublicKey;
    _activeGroupChatId = null;
  }

  void enterGroupChat(String groupId) {
    _activeGroupChatId = groupId;
    _activeDirectChatKey = null;
  }

  void exitChat() {
    _activeDirectChatKey = null;
    _activeGroupChatId = null;
  }

  bool isDirectChatActive(String peerPublicKey) =>
      _activeDirectChatKey == peerPublicKey;

  bool isGroupChatActive(String groupId) =>
      _activeGroupChatId == groupId;
}
