import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tea_order.dart';
import '../providers/drink_selection_provider.dart';
import '../utils/drink_utils.dart';

class DrinkCard extends StatelessWidget {
  final DrinkType drinkType;

  const DrinkCard({
    super.key,
    required this.drinkType,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkSelectionProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedDrink == drinkType;
        
        return Card(
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFF8B4513) : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => provider.selectDrink(isSelected ? null : drinkType),
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        getDrinkIcon(drinkType),
                        size: 32,
                        color: isSelected ? const Color(0xFF8B4513) : Colors.grey[700],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        drinkType.toString().split('.').last.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF8B4513) : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: const Color(0xFF8B4513),
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
