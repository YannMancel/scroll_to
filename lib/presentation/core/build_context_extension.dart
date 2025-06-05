import 'package:flutter/widgets.dart';

extension BuildContextExt on BuildContext {
  List<Element> whereChildElements(
    ConditionalElementVisitor test, {
    bool canOnlySearchOnVisibleElements = false,
    bool canContinueToSearchIntoChildElementsIfTestIsValid = true,
  }) {
    final childElements = <Element>[];
    final validElements = <Element>[];

    visitChildElements((element) {
      final isNotVisibleElement =
          element.renderObject?.paintBounds.size.isEmpty ?? true;
      if (canOnlySearchOnVisibleElements && isNotVisibleElement) return;

      final isValidTest = test(element);
      if (isValidTest) validElements.add(element);

      if (isValidTest && !canContinueToSearchIntoChildElementsIfTestIsValid) {
        return;
      }
      childElements.add(element);
    });

    if (childElements.isEmpty) return validElements;

    return <Element>[
      ...validElements,
      for (final element in childElements)
        ...element.whereChildElements(
          test,
          canOnlySearchOnVisibleElements: canOnlySearchOnVisibleElements,
          canContinueToSearchIntoChildElementsIfTestIsValid:
              canContinueToSearchIntoChildElementsIfTestIsValid,
        ),
    ];
  }
}
