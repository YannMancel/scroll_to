import 'package:flutter/cupertino.dart';
import 'package:scroll_to/item.dart';

abstract interface class SelectedCategoryController {
  ValueNotifier<CategoryItem?> get selectedCategory;
  set visibleItems(List<Item> values);
  void dispose();
}

class SelectedCategoryControllerImpl implements SelectedCategoryController {
  SelectedCategoryControllerImpl({
    required List<Item> allItems,
  })  : _allItems = allItems,
        _notifier = ValueNotifier<CategoryItem?>(null);

  final List<Item> _allItems;
  final ValueNotifier<CategoryItem?> _notifier;

  @override
  ValueNotifier<CategoryItem?> get selectedCategory => _notifier;

  @override
  set visibleItems(List<Item> items) {
    if (items.isEmpty) return;

    for (var i = items.first.index; i >= 0; i--) {
      final item = _allItems[i];
      if (item is CategoryItem) {
        _notifier.value = item;
        break;
      }
    }
  }

  @override
  void dispose() => _notifier.dispose();
}
