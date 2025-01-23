import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/voice_utils.dart';

class AudioProvider extends ChangeNotifier {
  String? _currentlyPlayingOrderId;
  String? get currentlyPlayingOrderId => _currentlyPlayingOrderId;
  Stream<PlayerState> get playerStateStream => VoiceUtils.playerStateStream;

  void playAudio(String orderId, String base64Audio) async {
    if (_currentlyPlayingOrderId == orderId) {
      await stopPlayback();
      return;
    }

    _currentlyPlayingOrderId = orderId;
    notifyListeners();

    await VoiceUtils.playAudio(base64Audio);
    _currentlyPlayingOrderId = null;
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await VoiceUtils.stopPlayback();
    _currentlyPlayingOrderId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    VoiceUtils.dispose();
    super.dispose();
  }
}
