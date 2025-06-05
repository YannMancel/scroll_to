import 'package:flutter/foundation.dart';

@immutable
sealed class Item<T> {
  const Item(
    this.index, {
    required this.value,
  });

  final int index;
  final T value;
}

@immutable
class CategoryItem<T> extends Item<T> {
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
  const ProductItem(
    super.index, {
    required super.value,
    required this.subIndex,
  });

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

extension ItemExt<T> on Item<T> {
  R when<R>({
    required R Function(int index, T value) category,
    required R Function(int index, T value, int subIndex) product,
  }) {
    return switch (this) {
      CategoryItem<T>() => category(index, value),
      ProductItem<T>(:final subIndex) => product(index, value, subIndex),
    };
  }

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

extension ItemsExt<T> on Iterable<Item<T>> {
  Iterable<CategoryItem<T>> get categories {
    return where(
      (item) => item.map<bool>(
        category: (_) => true,
        product: (_) => false,
      ),
    ).cast<CategoryItem<T>>();
  }
}
