import 'dart:isolate';

import 'package:scroll_to/domain/entities/item.dart';

/// A use case that generates a list of [Item] objects organized in a
/// hierarchical structure.
///
/// This class creates a list containing [CategoryItem] objects, each followed
/// by a specified number of related [ProductItem] objects. The generation is
/// performed in a separate isolate to avoid blocking the main thread.
class FindAllUseCase {
  const FindAllUseCase();

  /// Generates a list of [Item] objects with categories and their related
  /// products.
  ///
  /// The returned list will contain [categoryCount] categories, each followed by
  /// [productCountPerCategory] products. Each item has a unique index, and
  /// products are linked to their parent category through naming convention.
  ///
  /// Parameters:
  /// - [categoryCount]: The number of categories to generate (default: 100)
  /// - [productCountPerCategory]: The number of products per category
  ///   (default: 10)
  ///
  /// Returns a [Future] that completes with an [Iterable] of [Item] objects.
  Future<Iterable<Item<String>>> call({
    int categoryCount = 100,
    int productCountPerCategory = 10,
  }) async {
    return Isolate.run(() {
      final items = Iterable<CategoryItem<String>>.generate(
        categoryCount,
        (index) => CategoryItem<String>(
          index * (1 + productCountPerCategory),
          value: 'Category $index',
        ),
      ).fold(
        const <Item<String>>[],
        (join, e) => <Item<String>>[
          ...join,
          e,
          ...Iterable<Item<String>>.generate(
            productCountPerCategory,
            (index) => ProductItem<String>(
              e.index + index + 1,
              value: 'Product $index of ${e.value}',
              subIndex: index,
            ),
          ),
        ],
      );
      return items;
    });
  }
}
