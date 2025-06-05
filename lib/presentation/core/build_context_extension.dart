import 'package:flutter/widgets.dart';
import 'package:scroll_to/domain/entities/element_node.dart';

extension BuildContextExt on BuildContext {
  List<Widget> whereChildWidgets(
    ConditionalElementVisitor test, {
    bool canOnlySearchVisibleChildren = false,
  }) {
    final elements = <Element>[];
    final children = <Widget>[];

    visitChildElements((element) {
      final isNotVisibleElement =
          element.renderObject?.paintBounds.size.isEmpty ?? true;

      if (canOnlySearchVisibleChildren && isNotVisibleElement) return;

      elements.add(element);
      if (test(element)) children.add(element.widget);
    });

    if (elements.isEmpty) return const <Widget>[];

    return <Widget>[
      ...children,
      for (final element in elements)
        ...element.whereChildWidgets(
          test,
          canOnlySearchVisibleChildren: canOnlySearchVisibleChildren,
        ),
    ];
  }

  ElementNode get elementNodes {
    final childElements = <Element>[];
    visitChildElements(
      (element) => childElements.add(element),
    );

    if (childElements.isEmpty) return NoChildNode(this as Element);

    return ChildrenNode(
      this as Element,
      nodes: <ElementNode>[
        for (final element in childElements) element.elementNodes,
      ],
    );
  }
}
