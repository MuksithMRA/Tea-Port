import 'package:flutter/foundation.dart';
import '../models/tea_order.dart';

class DrinkSelectionProvider with ChangeNotifier {
  DrinkType? _selectedDrink;

  DrinkType? get selectedDrink => _selectedDrink;

  void selectDrink(DrinkType? drink) {
    _selectedDrink = drink;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDrink = null;
    notifyListeners();
  }
}
