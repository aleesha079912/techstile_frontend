import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';

class DesktopAdminShell extends StatelessWidget {
  final Widget body;
  final int? currentIndex;
  final ValueChanged<int>? onTabSelected;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? mobileDrawer;
  final double maxContentWidth;

  const DesktopAdminShell({
    super.key,
    required this.body,
    this.currentIndex,
    this.onTabSelected,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.mobileDrawer,
    this.maxContentWidth = 1400,
  });

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 850;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);

    if (!desktop) {

      return Scaffold(
        backgroundColor: AppTheme.background,
        drawer: mobileDrawer,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Row(
        children: [

          SizedBox(
            width: 270,
            child: OwnerDrawer(
              isPermanent: true,
              selectedIndex: currentIndex,
              onTabSelected: onTabSelected,
            ),
          ),

          Container(
            width: 1,
            color: AppTheme.primary.withOpacity(0.08),
          ),

          Expanded(
            child: Column(
              children: [
                if (title != null || actions != null)
                  _buildDesktopTopBar(context),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
