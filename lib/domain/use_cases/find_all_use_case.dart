import 'dart:isolate';

import 'package:scroll_to/domain/entities/item.dart';

class FindAllUseCase {
  const FindAllUseCase();

  Future<Iterable<Item<String>>> call({
    int categoryCount = 100,
    int productCount = 10,
  }) async {
    return Isolate.run(() {
      final items = Iterable<CategoryItem<String>>.generate(
        categoryCount,
        (index) => CategoryItem<String>(
          index * (1 + productCount),
          value: 'Category $index',
        ),
      ).fold(
        const <Item<String>>[],
        (join, e) => <Item<String>>[
          ...join,
          e,
          ...Iterable<Item<String>>.generate(
            productCount,
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
