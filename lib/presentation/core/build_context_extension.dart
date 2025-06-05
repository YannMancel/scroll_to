import 'package:flutter/widgets.dart';
import 'package:scroll_to/domain/entities/element_node.dart';

extension BuildContextExt on BuildContext {
  List<Widget> whereChildWidgets(
    ConditionalElementVisitor test, {
    bool canOnlySearchOnVisibleElements = false,
    bool canContinueToSearchIntoChildElementsIfTestIsValid = true,
  }) {
    final elements = <Element>[];
    final children = <Widget>[];

    visitChildElements((element) {
      final isNotVisibleElement =
          element.renderObject?.paintBounds.size.isEmpty ?? true;
      if (canOnlySearchOnVisibleElements && isNotVisibleElement) return;

      final isValidTest = test(element);
      if (isValidTest) children.add(element.widget);

      if (isValidTest && !canContinueToSearchIntoChildElementsIfTestIsValid) {
        return;
      }
      elements.add(element);
    });

    if (elements.isEmpty) return children;

    return <Widget>[
      ...children,
      for (final element in elements)
        ...element.whereChildWidgets(
          test,
          canOnlySearchOnVisibleElements: canOnlySearchOnVisibleElements,
          canContinueToSearchIntoChildElementsIfTestIsValid:
              canContinueToSearchIntoChildElementsIfTestIsValid,
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
