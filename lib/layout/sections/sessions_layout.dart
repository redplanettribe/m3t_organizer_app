import 'package:flutter/material.dart';

final class SessionsLayout extends StatelessWidget {
  const SessionsLayout({
    required this.isExpanded,
    required this.selectorSheet,
    required this.sessionContent,
    super.key,
  });

  static const double sheetTopPadding = 10;
  static const double sheetBottomSpacing = 8;

  final bool isExpanded;
  final Widget selectorSheet;
  final Widget sessionContent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSheetHeight =
            constraints.maxHeight - sheetTopPadding - sheetBottomSpacing;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, sheetTopPadding, 12, 0),
              child: _SessionDropdownContainer(
                isExpanded: isExpanded,
                expandedHeight: maxSheetHeight,
                child: selectorSheet,
              ),
            ),
            Expanded(child: sessionContent),
          ],
        );
      },
    );
  }
}

final class _SessionDropdownContainer extends StatelessWidget {
  const _SessionDropdownContainer({
    required this.isExpanded,
    required this.expandedHeight,
    required this.child,
  });

  final bool isExpanded;
  final double expandedHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const dropdownBorderRadius = BorderRadius.all(Radius.circular(24));

    return ClipRRect(
      borderRadius: dropdownBorderRadius,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: isExpanded
            ? SizedBox(
                height: expandedHeight,
                child: child,
              )
            : child,
      ),
    );
  }
}
