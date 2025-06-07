import 'package:flutter/cupertino.dart';
import 'package:scroll_to/domain/entities/item.dart';

/// A controller that tracks the currently selected category based on visible
/// items in a scrollable view.
///
/// This controller is typically used in conjunction with a scrollable list of
/// items where categories and products are displayed. It helps maintain the
/// state of which category is currently visible or selected in the viewport.
///
/// The generic type [T] represents the type of value stored in the [Item]
/// entities.
abstract interface class SelectedCategoryController<T> {
  /// A [ValueNotifier] that provides the currently selected [CategoryItem].
  ///
  /// This can be used with [ValueListenableBuilder] to rebuild UI when the
  /// selected category changes. The value may be null if no category is
  /// selected.
  ValueNotifier<CategoryItem<T>?> get selectedCategory;

  /// Updates the controller with the list of currently visible items in the
  /// viewport.
  ///
  /// When this setter is called with a list of visible items, the controller
  /// will determine which category these items belong to and update the
  /// [selectedCategory] accordingly.
  ///
  /// If the list is empty, no update will occur.
  set visibleItems(List<Item<T>> values);

  /// Releases resources used by this controller.
  ///
  /// This method should be called when the controller is no longer needed to
  /// prevent memory leaks.
  void dispose();
}

/// Default implementation of [SelectedCategoryController] that determines the
/// selected category based on the first visible item in the viewport.
///
/// This implementation searches backwards from the first visible item to find
/// the nearest category item that precedes it.
class SelectedCategoryControllerImpl<T>
    implements SelectedCategoryController<T> {
  /// Creates a new [SelectedCategoryControllerImpl].
  ///
  /// Requires a list of all items ([allItems]) that will be displayed in the
  /// scrollable view. This list should contain both category and product items
  /// in the order they appear in the UI.
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

    // Starting from the first visible item, search backwards to find the
    // nearest category
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
