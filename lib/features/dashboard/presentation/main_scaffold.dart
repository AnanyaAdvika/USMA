import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/offline_banner.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.schemes) || location.startsWith(AppRoutes.applications)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.documents)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.disbursements)) {
      return 3;
    }
    if (location.startsWith(AppRoutes.chatbot)) {
      return 4;
    }
    return 0; // Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.applications);
        break;
      case 2:
        context.go(AppRoutes.documents);
        break;
      case 3:
        context.go(AppRoutes.disbursements);
        break;
      case 4:
        context.go(AppRoutes.chatbot);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school_rounded),
            label: 'Schemes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_rupee_rounded),
            activeIcon: Icon(Icons.currency_rupee_rounded),
            label: 'DBT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy_rounded),
            label: 'Saathi AI',
          ),
        ],
      ),
    );
  }
}
