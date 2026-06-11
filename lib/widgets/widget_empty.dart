import 'package:flutter/material.dart';
import 'package:plugin_helper/index.dart';

/// Show empty data inline
class MyWidgetEmpty extends StatelessWidget {
  // How the children should be placed along the main axis in a flex layout.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the cross axis in a flex layout.
  final CrossAxisAlignment crossAxisAlignment;

  /// Empty message to show
  final String? message;

  /// The style of the text
  final TextStyle textStyle;

  /// Customize empty icon above [message]
  final Widget? icon;

  /// Trigger when the user pull to refresh page if [refreshController] not null.
  final VoidCallback? onRefresh;

  /// Customize a header indicator displace before content
  final Widget? customHeaderRefresh;

  /// This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  /// Custom widget
  final Widget? child;

  const MyWidgetEmpty({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.message,
    required this.textStyle,
    this.icon,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.onRefresh,
    this.customHeaderRefresh,
    this.enablePullDown = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    var childWidget = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (icon != null) icon!,
        if (icon != null) 14.h,
        Text(
          message ?? MyPluginMessageRequire.emptyData,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (enablePullDown) {
      return CustomMaterialIndicator(
        onRefresh: () async {
          onRefresh?.call();
        },
        child: child ?? childWidget,
      );
    }

    return child ?? childWidget;
  }
}
