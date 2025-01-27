import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tea_order.dart';
import '../providers/drink_selection_provider.dart';
import '../utils/drink_utils.dart';

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
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkSelectionProvider>(
      builder: (context, provider, _) {
        final selectedDrink = provider.selectedDrink;
        final screenSize = MediaQuery.of(context).size;
        final width = screenSize.width;
        
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          bottom: 16,
          right: selectedDrink != null ? 16 : -320,
          child: SafeArea(
            child: Container(
              width: 320,
              constraints: BoxConstraints(
                maxWidth: width - 32,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedDrink != null
                              ? getDrinkIcon(selectedDrink)
                              : Icons.local_cafe,
                          color: const Color(0xFF8B4513),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedDrink != null
                                ? selectedDrink.toString().split('.').last.toUpperCase()
                                : 'Select a Drink',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.selectDrink(null),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF8B4513),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (selectedDrink != null) ...[
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: 'Add a note (optional)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: widget.isLoading || selectedDrink == null
                                ? null
                                : () {
                                    widget.onPlaceOrder(
                                      selectedDrink,
                                      _noteController.text.trim().isNotEmpty
                                          ? _noteController.text.trim()
                                          : null,
                                    );
                                    provider.selectDrink(null);
                                    _noteController.clear();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Place Order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
