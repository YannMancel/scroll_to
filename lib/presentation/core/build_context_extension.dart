import 'package:flutter/widgets.dart';

/// Extension on [BuildContext] that provides utility methods for working with
/// the element tree.
extension BuildContextExt on BuildContext {
  /// Recursively searches through child elements in the element tree and
  /// returns a list of elements that match the given test condition.
  ///
  /// This method traverses the element tree starting from the current context
  /// and applies the [test] function to each child element. Elements that pass
  /// the test are included in the returned list.
  ///
  /// Parameters:
  /// - [test]: A function that takes an [Element] and returns a boolean
  ///   indicating whether the element matches the desired criteria.
  /// - [canOnlySearchOnVisibleElements]: When true, only visible elements
  ///   (those with non-empty paint bounds) will be considered.
  ///   Defaults to false.
  /// - [canContinueToSearchIntoChildElementsIfTestIsValid]: When true, the
  ///   search will continue into the children of elements that pass the test.
  ///   When false, the search stops at elements that pass the test.
  ///   Defaults to true.
  ///
  /// Returns a list of all [Element]s in the element tree that match the test
  /// condition.
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
