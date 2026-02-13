import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/services.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../home/home_view.dart';
import '../calendar/calendar_view.dart';
import 'main_view_model.dart';

import '../../widgets/floating_tab_bar.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({
    super.key,
    this.initialIndex = 0,
    this.initialSubTab = 0,
  });

  final int initialIndex;
  final int initialSubTab;

  @override
  Widget builder(
  // ...
    BuildContext context,
    MainViewModel viewModel,
    Widget? child,
  ) {
    // Explicitly enforce transparent system UI for this view
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true, // Allow body to extend behind bottom areas
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Content Layer
            IndexedStack(
              index: viewModel.currentIndex,
              children: [
                const HomeView(), // Index 0
                const CalendarView(), // Index 1
                _buildPlaceholder('Settings'), // Index 2
              ],
            ),

            // 2. Gradient Overlay (Fade out effect)
            Positioned(
              left: 0, 
              right: 0, 
              bottom: 0,
              height: 140,
              child: IgnorePointer( // Allow click through to list if needed in upper transparent area (though pointer events might be blocked if not careful, ignore pointer is safest if it's just visual)
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.background, // Solid at bottom (slate50)
                        AppColors.background.withValues(alpha: 0.0), // Transparent at top
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Floating TabBar (Prototype Style)
            Positioned(
              bottom: 32, 
              left: 24, // Matching card margins (24px)
              right: 24,
              child: FloatingTabBar(
                currentIndex: viewModel.currentIndex,
                onTabTap: (index) => viewModel.setIndex(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(title, style: const TextStyle(fontSize: 24, color: AppColors.textPrimary)),
      ),
    );
  }




  @override
  MainViewModel viewModelBuilder(BuildContext context) => MainViewModel();

  @override
  void onViewModelReady(MainViewModel viewModel) {
    if (MainViewModel.requestShopTab) {
      viewModel.activateShopMode();
      MainViewModel.requestShopTab = false;
    }

    if (initialIndex > 0) {
      viewModel.setIndex(initialIndex);
      // We also need to pass initialSubTab to the relevant child view model, 
      // but MainViewModel knows nothing about CalendarViewModel directly unless we use a service for state sharing 
      // or if we rely on the constructor of CalendarView.
      // A simple way: Use a static/global signal or a service. 
      // For now, let's keep it simple: We just switch to the Calendar tab. 
      // The "Shop" sub-tab selection might need a service or we can pass it down if we restructure.
      // Wait! CalendarView is inside IndexedStack. It's const CalendarView().
      // We can't pass data easily without rebuilding MainView structure or using a Service.
      // Let's use `SharedStateService` or similar if exists. 
      // Or: CalendarViewModel can read `MainViewArguments` if we pass them? No.
      // BEST: Add `MainViewModel.initialSubTab` and use a service to notify CalendarViewModel.
      
      if (initialIndex == 1 && initialSubTab == 1) {
        viewModel.activateShopMode();
      }
    }
  }
}
