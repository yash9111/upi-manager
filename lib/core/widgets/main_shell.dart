import 'package:flutter/material.dart';
import 'package:upi_tracker/features/budget/presentation/screens/budget_screen.dart';
import 'package:upi_tracker/features/expenses/presentation/screens/expense_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splits/presentation/screens/splits_screen.dart';
import 'app_bottom_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState
    extends State<MainShell> {
  int currentIndex = 0;

  final screens = const [
    DashboardScreen(),
    BudgetScreen(),
    SplitsScreen(),
    ExpensesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: AppBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}