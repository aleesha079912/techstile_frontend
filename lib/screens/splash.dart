import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,

      body: Stack(
        children: [
          // =====================================================
          // FULL SCREEN BACKGROUND IMAGE (30% OPACITY)
          // =====================================================
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/images/machines.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Optional: a subtle overlay so text stays readable
          // over the background image regardless of image content.
          Positioned.fill(
            child: Container(
              color: AppTheme.background.withOpacity(0.4),
            ),
          ),

          // =====================================================
          // FOREGROUND CONTENT
          // =====================================================
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

                    child: IntrinsicHeight(
                      child: Column(
                        children: [

                          // =====================================================
                          // TOP SECTION (CENTERED)
                          // =====================================================
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),

                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    // INDUSTRIAL INTELLIGENCE
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.precision_manufacturing,
                                          size: 18,
                                          color: AppTheme.primary,
                                        ),

                                        const SizedBox(width: 6),

                                        Flexible(
                                          child: Text(
                                            "INDUSTRIAL INTELLIGENCE",
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.1,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: constraints.maxHeight < 600
                                          ? 28
                                          : 45,
                                    ),
                                    
                                    // =================================================
                                    // LOGO ICON (commented out, kept as-is)
                                    // =================================================
                                    Container(
                                      height: constraints.maxWidth < 380
                                          ? 78
                                          : 88,

                                      width: constraints.maxWidth < 380
                                          ? 78
                                          : 88,

                                      decoration: BoxDecoration(
                                        color: AppTheme.secondary,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: AppTheme.softShadow,
                                      ),

                                      child: const Icon(
                                        Icons.tune,
                                        size: 40,
                                        color: AppTheme.primary,
                                      ),
                                    ),

                                    SizedBox(
                                      height: constraints.maxHeight < 600
                                          ? 20
                                          : 28,
                                    ),






                                    // =================================================
                                    // APP NAME
                                    // =================================================
                                    Text(
                                      "TECHstile",
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: constraints.maxWidth < 380
                                            ? 27
                                            : 30,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // =================================================
                                    // DESCRIPTION
                                    // =================================================
                                    Text(
                                      "Precision orchestration for high-performance "
                                      "textile manufacturing.",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textPrimary.withOpacity(0.7),
                                        height: 1.45,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // =================================================
                                    // SMALL LINE
                                    // =================================================
                                    Container(
                                      width: 40,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // =====================================================
                          // GET STARTED BUTTON
                          // =====================================================
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),

                            child: SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/login');
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.secondary,

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Get Started",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    SizedBox(width: 8),

                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: constraints.maxHeight < 600
                                ? 18
                                : 25,
                          ),
                          const SizedBox(height: 2),

       

                          SizedBox(
                            height: constraints.maxHeight < 600
                                ? 18
                                : 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}