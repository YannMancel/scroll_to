import 'package:flutter/foundation.dart';

/// Base class representing an item in a hierarchical list structure.
///
/// This is a sealed class that serves as the parent for [CategoryItem] and
/// [ProductItem].
/// Each item has a unique [index] and a [value] of generic type [T].
@immutable
sealed class Item<T> {
  /// Creates a new instance of [Item].
  ///
  /// Parameters:
  /// - [index]: A unique identifier for the item
  /// - [value]: The data associated with this item
  const Item(
    this.index, {
    required this.value,
  });

  /// The unique identifier for this item.
  final int index;

  /// The data value associated with this item.
  final T value;
}

@immutable
class CategoryItem<T> extends Item<T> {
  /// Creates a new instance of [CategoryItem].
  ///
  /// Parameters:
  /// - [index]: A unique identifier for the category
  /// - [value]: The data associated with this category
  const CategoryItem(
    super.index, {
    required super.value,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is CategoryItem &&
            index == other.index &&
            value == other.value);
  }

  @override
  int get hashCode {
    return Object.hashAll(
      <Object?>[
        runtimeType,
        index,
        value,
      ],
    );
  }
}

@immutable
class ProductItem<T> extends Item<T> {
  /// Creates a new instance of [ProductItem].
  ///
  /// Parameters:
  /// - [index]: A unique identifier for the product
  /// - [value]: The data associated with this product
  /// - [subIndex]: The position of this product within its category
  const ProductItem(
    super.index, {
    required super.value,
    required this.subIndex,
  });

  /// The position of this product within its category.
  ///
  /// This is used to identify the product's order in relation to other products
  /// in the same category.
  final int subIndex;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is ProductItem &&
            index == other.index &&
            value == other.value &&
            subIndex == other.subIndex);
  }

  @override
  int get hashCode {
    return Object.hashAll(
      <Object?>[
        runtimeType,
        index,
        value,
        subIndex,
      ],
    );
  }
}

/// Extension methods for the [Item] class to enable pattern matching.
///
/// These methods provide a convenient way to handle different item types
/// without explicit type checking or casting.
extension ItemExt<T> on Item<T> {
  /// Pattern matches on the item type and applies the appropriate function.
  ///
  /// This method extracts the item's properties and passes them to the appropriate
  /// callback function based on the item's type.
  ///
  /// Parameters:
  /// - [category]: Function to apply if this is a [CategoryItem]
  /// - [product]: Function to apply if this is a [ProductItem]
  ///
  /// Returns the result of the applied function with type [R].
  R when<R>({
    required R Function(int index, T value) category,
    required R Function(int index, T value, int subIndex) product,
  }) {
    return switch (this) {
      CategoryItem<T>() => category(index, value),
      ProductItem<T>(:final subIndex) => product(index, value, subIndex),
    };
  }

  /// Maps this item to a result based on its concrete type.
  ///
  /// Unlike [when], this method passes the entire item object to the callback
  /// function, allowing for more complex operations on the item.
  ///
  /// Parameters:
  /// - [category]: Function to apply if this is a [CategoryItem]
  /// - [product]: Function to apply if this is a [ProductItem]
  ///
  /// Returns the result of the applied function with type [R].
  R map<R>({
    required R Function(CategoryItem<T> type) category,
    required R Function(ProductItem<T> type) product,
  }) {
    return switch (this) {
      CategoryItem<T>() => category(this as CategoryItem<T>),
      ProductItem<T>() => product(this as ProductItem<T>),
    };
  }
}

/// Extension methods for collections of [Item] objects.
///
/// These methods provide convenient ways to filter and manipulate
/// collections of items based on their types.
extension ItemsExt<T> on Iterable<Item<T>> {
  /// Filters the collection to include only [CategoryItem] objects.
  ///
  /// This getter uses the [map] method from [ItemExt] to identify and filter
  /// only the category items from the collection.
  ///
  /// Returns an [Iterable] containing only the [CategoryItem] objects from
  /// the original collection.
  Iterable<CategoryItem<T>> get categories {
    return where(
      (item) => item.map<bool>(
        category: (_) => true,
        product: (_) => false,
      ),
    ).cast<CategoryItem<T>>();
  }
}
