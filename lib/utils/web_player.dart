import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class WebPlayer {
  static void play(
      {required List<int> bytes, required AudioPlayer audioPlayer}) async {
    debugPrint('Playing audio on web platform');
    // Create a blob URL for web playback
    final blob = html.Blob([bytes], 'audio/m4a');
    final url = html.Url.createObjectUrlFromBlob(blob);
    debugPrint('Created blob URL: $url');

    await audioPlayer.play(UrlSource(url));

    // Clean up the blob URL after playback
    audioPlayer.onPlayerComplete.listen((_) {
      html.Url.revokeObjectUrl(url);
      debugPrint('Cleaned up blob URL');
    });
  }
}
