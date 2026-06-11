import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:plugin_helper/index.dart';

/// Show error message inline
class MyWidgetError extends StatelessWidget {
  // How the children should be placed along the main axis in a flex layout.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the cross axis in a flex layout.
  final CrossAxisAlignment crossAxisAlignment;

  /// Error message to show.
  final String error;

  /// A callback to be called when the user pull to refresh. If [refreshController] is active.
  final VoidCallback? onRefresh;

  /// Change to a widget to show above [error]
  final Widget? iconError;

  /// The style of the text.
  final TextStyle textStyle;

  /// This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  /// Customize a header indicator displace before content. Only for Android/iOS.
  final Widget? customHeaderRefresh;

  /// Custom widget
  final Widget? child;

  const MyWidgetError({
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
    required this.error,
    required this.textStyle,
    this.onRefresh,
    this.iconError,
    this.enablePullDown = true,
    this.customHeaderRefresh,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    var childWidget = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        iconError ?? const Icon(Icons.error_outline, size: 20),
        5.h,
        Text(error, textAlign: TextAlign.center, style: textStyle),
      ],
    );

    if (enablePullDown) {
      return CustomMaterialIndicator(
        onRefresh: () async {
          onRefresh.call();
        },
        child: child ?? childWidget,
      );
    }

    return child ?? childWidget;
  }
}
