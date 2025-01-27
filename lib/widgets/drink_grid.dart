import 'package:flutter/material.dart';
import '../models/tea_order.dart';
import 'drink_card.dart';

class DrinkGrid extends StatelessWidget {
  const DrinkGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: DrinkType.values.length,
      itemBuilder: (context, index) {
        final drinkType = DrinkType.values[index];
        return DrinkCard(drinkType: drinkType);
      },
    );
  }
}
