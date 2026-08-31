
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

      body: SafeArea(
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
                      // TOP SECTION
                      // =====================================================
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),

                        child: Column(
                          children: [

                            SizedBox(
                              height: constraints.maxHeight < 600
                                  ? 22
                                  : 30,
                            ),

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
                            // LOGO ICON
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

                      // =====================================================
                      // FLEXIBLE SPACE
                      // =====================================================
                      const Spacer(),

                      // =====================================================
                      // FACTORY IMAGE
                      // =================================================
                     Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 20,
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Image.asset(
      "assets/images/logo.png", 
      height: 120, 
      fit: BoxFit.contain, 
   
    ),
  ),
),

                      SizedBox(
                        height: constraints.maxHeight < 600
                            ? 14
                            : 20,
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
    );
  }
}

