import 'package:flutter/widgets.dart';

@immutable
sealed class ElementNode {
  const ElementNode(this.element);

  final Element element;
}

@immutable
class NoChildNode extends ElementNode {
  const NoChildNode(super.element);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is NoChildNode &&
            element == other.element);
  }

  @override
  int get hashCode {
    return Object.hashAll(
      <Object?>[
        runtimeType,
        element,
      ],
    );
  }
}

@immutable
class ChildrenNode extends ElementNode {
  const ChildrenNode(
    super.element, {
    required this.nodes,
  });

  final List<ElementNode> nodes;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is ChildrenNode &&
            element == other.element &&
            nodes == other.nodes);
  }

  @override
  int get hashCode {
    return Object.hashAll(
      <Object?>[
        runtimeType,
        element,
        nodes,
      ],
    );
  }
}

extension ElementNodeExt on ElementNode {
  T when<T>({
    required T Function(Element element) noChild,
    required T Function(Element element, List<ElementNode> nodes) children,
  }) {
    return switch (this) {
      NoChildNode() => noChild(element),
      ChildrenNode(:final nodes) => children(element, nodes),
    };
  }
}
