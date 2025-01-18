import 'package:flutter/material.dart';
import '../models/tea_order.dart';
import 'drink_card.dart';

class DrinkGrid extends StatelessWidget {
  const DrinkGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: DrinkType.values.length,
      itemBuilder: (context, index) {
        final drinkType = DrinkType.values[index];
        return DrinkCard(drinkType: drinkType);
      },
    );
  }
}
