import 'package:flutter/cupertino.dart';
import 'package:scroll_to/domain/entities/item.dart';

abstract interface class SelectedCategoryController<T> {
  ValueNotifier<CategoryItem<T>?> get selectedCategory;
  set visibleItems(List<Item<T>> values);
  void dispose();
}

class SelectedCategoryControllerImpl<T>
    implements SelectedCategoryController<T> {
  SelectedCategoryControllerImpl({
    required List<Item<T>> allItems,
  })  : _allItems = allItems,
        _notifier = ValueNotifier<CategoryItem<T>?>(null);

  final List<Item<T>> _allItems;
  final ValueNotifier<CategoryItem<T>?> _notifier;

  @override
  ValueNotifier<CategoryItem<T>?> get selectedCategory => _notifier;

  @override
  set visibleItems(List<Item<T>> items) {
    if (items.isEmpty) return;

    for (var i = items.first.index; i >= 0; i--) {
      final item = _allItems[i];
      if (item is CategoryItem<T>) {
        _notifier.value = item;
        break;
      }
    }
  }

  @override
  void dispose() => _notifier.dispose();
}
