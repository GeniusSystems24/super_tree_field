import 'package:flutter/material.dart';

/// Breakpoints used by the example application.
///
/// The values follow common Flutter adaptive-layout ranges:
/// compact layouts are phone-sized, medium layouts cover tablets and small
/// desktop windows, and expanded layouts cover wider desktop windows.
abstract final class ExampleBreakpoints {
  /// The width below which the layout is treated as compact.
  static const double compact = 600;

  /// The width below which the layout is treated as medium.
  static const double medium = 1024;
}

/// A responsive page-body wrapper shared by the package examples.
///
/// The widget adapts horizontal and vertical padding to the available width,
/// centers the content, and constrains it to [maxWidth].
///
/// When [scrollable] is true, this widget owns vertical scrolling. Set
/// [scrollable] to false when [child] needs a bounded height, such as a
/// [Column] containing an internally scrolling [Scrollable].
class ResponsiveExampleLayout extends StatelessWidget {
  /// Creates a responsive example-page layout.
  const ResponsiveExampleLayout({
    super.key,
    required this.child,
    required this.maxWidth,
    this.scrollable = true,
  });

  /// The example content displayed inside the responsive bounds.
  final Widget child;

  /// The maximum width allowed for [child] on wide displays.
  final double maxWidth;

  /// Whether this wrapper owns vertical scrolling.
  ///
  /// Defaults to true. Use false for examples whose child must receive a
  /// bounded viewport height and manage its own scrolling.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final EdgeInsets padding;
          if (width < ExampleBreakpoints.compact) {
            padding = const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            );
          } else if (width < ExampleBreakpoints.medium) {
            padding = const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            );
          } else {
            padding = const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 32,
            );
          }

          final content = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          );

          if (!scrollable) {
            return Padding(
              padding: padding,
              child: content,
            );
          }

          return SingleChildScrollView(
            padding: padding,
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: content,
          );
        },
      ),
    );
  }
}
