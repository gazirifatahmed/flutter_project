import 'package:flutter/material.dart';
import '../model/menu_item_model.dart';
import '../service/menu_item_service.dart';


class MenuItemProvider with ChangeNotifier {
final MenuItemService _service = MenuItemService();
List<MenuItem> _items = [];
bool _isLoading = false;


List<MenuItem> get items => _items;
bool get isLoading => _isLoading;


Future<void> loadMenuItems() async {
_isLoading = true;
notifyListeners();


try {
_items = await _service.fetchMenuItems();
} catch (e) {
print('Error: $e');
}


_isLoading = false;
notifyListeners();
}


// ✅ Optional: Manual trigger if needed externally
void refresh(List<MenuItem> updatedItems) {
_items = updatedItems;
notifyListeners();
}
}