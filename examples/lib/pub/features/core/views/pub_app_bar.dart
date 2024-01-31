import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class PubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PubAppBar({
    super.key,
    this.bottom,
  });

  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final parentRoute = ModalRoute.of(context);

    final canGoBack = parentRoute?.impliesAppBarDismissal ?? false;

    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/pub/hero-bg-static.svg',
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (canGoBack) const BackButton(),
                  Expanded(
                    child: SvgPicture.asset(
                      'assets/pub/pub-dev-logo.svg',
                      width: 150,
                    ),
                  ),
                  if (canGoBack)
                    const Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: BackButton(),
                      ),
                    ),
                ],
              ),
              const Gap(16),
              if (bottom case final bottom?) bottom
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
