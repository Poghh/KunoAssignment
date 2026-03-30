import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/settings_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import 'display_name_setup_page.dart';
import 'setup_preferences_page.dart';
import '../../../expense/presentation/pages/expense_shell_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _SplashMetrics.animationDuration,
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(
      begin: _SplashMetrics.scaleBegin,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    Future<void>.delayed(_SplashMetrics.holdDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) return;

    final SettingsState settings = context.read<SettingsCubit>().state;
    final AuthState auth = context.read<AuthCubit>().state;

    Widget destination;
    if (!settings.hasCompletedSetup) {
      destination = const SetupPreferencesPage();
    } else if (auth.status == AuthStatus.guest) {
      destination = const ExpenseShellPage();
    } else if (auth.status == AuthStatus.authenticated) {
      final bool hasDisplayName = auth.displayName?.trim().isNotEmpty ?? false;
      destination =
          hasDisplayName ? const ExpenseShellPage() : const DisplayNameSetupPage();
    } else {
      destination = const ExpenseShellPage();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => destination,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: _SplashMetrics.fadeDuration,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppTheme.splashGradientStart,
              AppTheme.primary,
              AppTheme.splashGradientEnd,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: AppContainerSize.splashLogo,
                    height: AppContainerSize.splashLogo,
                    padding: const EdgeInsets.all(_SplashMetrics.logoPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.logo),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: _SplashMetrics.shadowAlpha),
                          blurRadius: _SplashMetrics.shadowBlur,
                          offset: const Offset(0, _SplashMetrics.shadowOffsetY),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/app-logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text(
                    'Kuno Spendy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _SplashMetrics.titleFontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: _SplashMetrics.titleLetterSpacing,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Track smarter, spend wiser',
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: _SplashMetrics.taglineAlpha),
                      fontSize: _SplashMetrics.taglineFontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashMetrics {
  const _SplashMetrics._();

  static const Duration animationDuration = Duration(milliseconds: 900);
  static const Duration holdDuration = Duration(milliseconds: 2000);
  static const Duration fadeDuration = Duration(milliseconds: 400);

  static const double scaleBegin = 0.82;
  static const double logoPadding = 14;
  static const double shadowAlpha = 0.18;
  static const double shadowBlur = 24;
  static const double shadowOffsetY = 8;
  static const double taglineAlpha = 0.8;
  static const double titleFontSize = 32;
  static const double taglineFontSize = 15;
  static const double titleLetterSpacing = 0.5;
}
