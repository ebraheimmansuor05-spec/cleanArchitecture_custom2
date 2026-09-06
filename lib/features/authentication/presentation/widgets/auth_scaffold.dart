import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;
  final Widget child;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF20252C), Color(0xFF11151A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 420
                  ? 20.0
                  : 32.0;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showBackButton)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                              onPressed: () => Navigator.of(context).maybePop(),
                              color: Colors.white,
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                        const SizedBox(height: 8),
                        const _BrandMark(),
                        const SizedBox(height: 18),
                        Text(
                          'authentication.brand_name'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'authentication.brand_tagline'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Card(
                          color: theme.colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  titleKey.tr(),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subtitleKey.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                child,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                            Text(
                              'authentication.secure_access'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.factory_outlined,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}
