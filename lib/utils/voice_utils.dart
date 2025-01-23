import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tea_port/utils/web_player_dummy.dart'
    if (kIsWeb) 'package:tea_port/utils/web_player.dart';

class VoiceUtils {
  static final _audioRecorder = Record();
  static final _audioPlayer = AudioPlayer();

  static Stream<PlayerState> get playerStateStream =>
      _audioPlayer.onPlayerStateChanged;

  static Future<bool> requestPermissions() async {
    if (kIsWeb) {
      // Web handles permissions differently through browser
      return true;
    }
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String path;
        if (kIsWeb) {
          // For web, we don't specify a path as it's handled internally
          path = '';
        } else {
          final tempDir = await path_provider.getTemporaryDirectory();
          path =
              '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder.start(
          path: path,
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  static Future<String?> stopRecording() async {
    try {
      if (await _audioRecorder.isRecording()) {
        final result = await _audioRecorder.stop();
        if (kIsWeb) {
          // For web platforms, stop() returns a blob URL
          if (result != null) {
            // Fetch the blob data and convert it to base64
            final response = await http.get(Uri.parse(result));
            final bytes = await response.bodyBytes;
            final base64String = base64Encode(bytes);
            return base64String;
          }
        } else {
          // For mobile platforms, stop() returns the file path
          if (result != null) {
            final file = File(result);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64String = base64Encode(bytes);
              await file.delete();
              return base64String;
            }
          }
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
    return null;
  }

  static Future<void> playAudio(String base64Audio) async {
    try {
      debugPrint(
          'Starting to play audio. Base64 length: ${base64Audio.length}');
      final bytes = base64Decode(base64Audio);
      debugPrint('Decoded bytes length: ${bytes.length}');

      if (kIsWeb) {
        WebPlayer.play(bytes: bytes, audioPlayer: _audioPlayer);
      } else {
        debugPrint('Playing audio on mobile platform');
        final tempDir = await path_provider.getTemporaryDirectory();
        final tempPath =
            '${tempDir.path}/temp_playback_${DateTime.now().millisecondsSinceEpoch}.m4a';

        final file = File(tempPath);
        await file.writeAsBytes(bytes);
        debugPrint('Temporary file written at: $tempPath');

        await _audioPlayer.play(DeviceFileSource(tempPath));

        // Delete the temporary file after playback
        _audioPlayer.onPlayerComplete.listen((_) async {
          if (await file.exists()) await file.delete();
          debugPrint('Temporary file deleted after playback');
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error playing audio: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<void> stopPlayback() async {
    await _audioPlayer.stop();
  }

  static Future<void> dispose() async {
    await _audioRecorder.dispose();
    await _audioPlayer.dispose();
  }
}
