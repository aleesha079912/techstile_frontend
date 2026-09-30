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
          
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/images/machines.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          
          Positioned.fill(
            child: Container(
              color: AppTheme.secondary.withOpacity(0.4),
            ),
          ),

         
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

                          
                          // TOP SECTION (CENTERED)
                          
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
                                    
                                   
                                    
                                 // LOGO ICON
                                 Container(
                                    height: constraints.maxWidth < 280 ? 100 : 150,
                                    width: constraints.maxWidth < 280 ? 100 : 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(38),
                                      border: Border.all(
                                        color: const Color(0xFF122B7A),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.onsurface.withOpacity(0.25),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: Image.asset(
                                        'assets/images/logo2.jpg',
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.image_not_supported, size: 32),
                                      ),
                                    ),
                                  ), 
                                      
                                      
                                 const SizedBox(height: 28), 
                                 Text(
                                    "TECHstile",
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: constraints.maxWidth < 380
                                          ? 27
                                          : 30,
                                    ),
                                  ),
                                   const SizedBox(height: 8),

                                    
                                    
                                   
                                    // SMALL LINE
                                   
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