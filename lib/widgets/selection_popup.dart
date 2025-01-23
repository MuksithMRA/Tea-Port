import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tea_order.dart';
import '../providers/drink_selection_provider.dart';
import '../utils/drink_utils.dart';
import '../utils/voice_utils.dart';

class SelectionPopup extends StatefulWidget {
  final Function(DrinkType, String?) onPlaceOrder;
  final bool isLoading;

  const SelectionPopup({
    super.key,
    required this.onPlaceOrder,
    required this.isLoading,
  });

  @override
  State<SelectionPopup> createState() => _SelectionPopupState();
}

class _SelectionPopupState extends State<SelectionPopup> {
  bool _isRecording = false;
  String? _recordedAudio;

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      final hasPermission = await VoiceUtils.requestPermissions();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }

      setState(() => _isRecording = true);
      await VoiceUtils.startRecording();
    } else {
      _recordedAudio = await VoiceUtils.stopRecording();
      setState(() => _isRecording = false);
    }
  }

  @override
  void dispose() {
    VoiceUtils.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkSelectionProvider>(
      builder: (context, provider, _) {
        final selectedDrink = provider.selectedDrink;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: selectedDrink != null ? 24 : -300,
          bottom: 24,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          selectedDrink != null
                              ? getDrinkIcon(selectedDrink)
                              : Icons.local_cafe,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Drink',
                              style: TextStyle(
                                color: Color(0xFF8B4513),
                                fontSize: 14,
                              ),
                            ),
                            if (selectedDrink != null)
                              Text(
                                selectedDrink.toString().split('.').last,
                                style: const TextStyle(
                                  color: Color(0xFF8B4513),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.selectDrink(null),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Ready to place your order?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (selectedDrink != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Add a voice note (optional)',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_recordedAudio != null)
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow),
                                      onPressed: () =>
                                          VoiceUtils.playAudio(_recordedAudio!),
                                    ),
                                  IconButton(
                                    icon: Icon(
                                        _isRecording ? Icons.stop : Icons.mic),
                                    color: _isRecording ? Colors.red : null,
                                    onPressed: _toggleRecording,
                                  ),
                                  if (_recordedAudio != null)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          setState(() => _recordedAudio = null),
                                    ),
                                ],
                              ),
                              if (_recordedAudio != null)
                                const Text(
                                  'Voice note recorded',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: widget.isLoading || selectedDrink == null
                              ? null
                              : () {
                                  widget.onPlaceOrder(
                                      selectedDrink, _recordedAudio);
                                  provider.selectDrink(null);
                                  setState(() => _recordedAudio = null);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
