/// Abstracts platform-specific system service checks and settings navigation.
abstract interface class SystemService {
  Stream<String> get serviceEventStream;
  Future<bool> get isWifiEnabled;
  Future<void> openBluetoothSettings();
  Future<void> openLocationSettings();
  Future<void> openWifiSettings();
}
