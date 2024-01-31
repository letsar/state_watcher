import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/widgets.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    this.actions,
    required this.child,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RoundedOutlinedBorder(
      clip: true,
      child: Column(
        children: [
          AreaPaneHeader(
            roundedTopBorder: false,
            includeTopBorder: false,
            actions: actions ?? const [],
            rightPadding: defaultSpacing,
            title: title,
            tall: true,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
