import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';

class DevToolsClearableTextField extends StatelessWidget {
  DevToolsClearableTextField({
    super.key,
    TextEditingController? controller,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.autofocus = false,
  }) : controller = controller ?? TextEditingController();

  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(denseSpacing),
        constraints: BoxConstraints(
          minHeight: defaultTextFieldHeight,
          maxHeight: defaultTextFieldHeight,
        ),
        border: const OutlineInputBorder(),
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            controller.clear();
            onChanged?.call('');
          },
        ),
        isDense: true,
      ),
    );
  }
}

Widget clearInputButton(VoidCallback onPressed) {
  return inputDecorationSuffixButton(Icons.clear, onPressed);
}

Widget closeSearchDropdownButton(VoidCallback? onPressed) {
  return inputDecorationSuffixButton(Icons.close, onPressed);
}

Widget inputDecorationSuffixButton(IconData icon, VoidCallback? onPressed) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: densePadding),
    height: inputDecorationElementHeight,
    width: defaultIconSize + denseSpacing,
    child: IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      iconSize: defaultIconSize,
      splashRadius: defaultIconSize,
      icon: Icon(icon),
    ),
  );
}
