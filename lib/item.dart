import 'package:flutter/foundation.dart';

@immutable
sealed class Item {
  const Item(
    this.index, {
    required this.label,
  });

  final int index;
  final String label;
}

@immutable
class CategoryItem extends Item {
  const CategoryItem(
    super.index, {
    required super.label,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is CategoryItem &&
            index == other.index &&
            label == other.label);
  }

  @override
  int get hashCode {
    return Object.hashAll(
      <Object?>[
        runtimeType,
        index,
        label,
      ],
    );
  }
}

@immutable
class ProductItem extends Item {
  const ProductItem(
    super.index, {
    required super.label,
    required this.subIndex,
  });

  final int subIndex;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is ProductItem &&
            index == other.index &&
            label == other.label &&
            subIndex == other.subIndex);
  }

  @override
  int get hashCode {
    return Object.hashAll(
      <Object?>[
        runtimeType,
        index,
        label,
        subIndex,
      ],
    );
  }
}

extension ItemExt on Item {
  T when<T>({
    required T Function(int index, String label) category,
    required T Function(int index, String label, int subIndex) product,
  }) {
    return switch (this) {
      CategoryItem() => category(index, label),
      ProductItem(:final subIndex) => product(index, label, subIndex),
    };
  }

  T map<T>({
    required T Function(CategoryItem type) category,
    required T Function(ProductItem type) product,
  }) {
    return switch (this) {
      CategoryItem() => category(this as CategoryItem),
      ProductItem() => product(this as ProductItem),
    };
  }
}

extension ItemsExt on Iterable<Item> {
  Iterable<CategoryItem> get categories {
    return where(
      (item) => item.map<bool>(
        category: (_) => true,
        product: (_) => false,
      ),
    ).cast<CategoryItem>();
  }
}
