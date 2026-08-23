import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/core/widgets/app_primary_button.dart';
import 'package:upi_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:upi_tracker/features/category/presentation/providers/category_provider.dart';
import 'package:upi_tracker/features/category/presentation/widgets/add_category_dialog.dart';
import 'package:upi_tracker/features/category/presentation/widgets/category_tile.dart';
import 'package:upi_tracker/features/profile/presentation/provider/saved_people_provider.dart';

import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../widgets/add_person_dialog.dart';
import '../widgets/import_result_dialog.dart';
import '../widgets/saved_person_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(savedPeopleProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return const AddPersonDialog();
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'Y',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 18),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expense Manager',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  'Manage your expenses smartly',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // BACKUP SECTION
                    const Text(
                      'Backup & Restore',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: buildActionCard(
                            icon: Icons.upload,
                            title: 'Export Data',
                            subtitle: 'Create backup file',
                            color: Colors.blue,
                            onTap: () async {
                              await BackupService.exportData();

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Backup ready to share'),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: buildActionCard(
                            icon: Icons.download,
                            title: 'Import Data',
                            subtitle: 'Restore backup',
                            color: Colors.green,
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              final result = await BackupService.importData();

                              ref
                                  .read(expensesProvider.notifier)
                                  .loadExpenses();

                              if (!context.mounted) {
                                return;
                              }

                              Navigator.pop(context);

                              showDialog(
                                context: context,
                                builder: (_) {
                                  return ImportResultDialog(result: result);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // SAVED PEOPLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Expense Categories',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return const AddCategoryDialog();
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 18),

                                SizedBox(width: 8),

                                Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    ListView.builder(
                      itemCount: categories.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return CategoryTile(
                          title: category.name,
                          isDefault: category.isDefault,
                          onDelete: () async {
                            await ref
                                .read(categoriesProvider.notifier)
                                .deleteCategory(category.id);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved People',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${people.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // PEOPLE LIST
            people.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No saved people',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: people.length,
                      itemBuilder: (context, index) {
                        final person = people[index];

                        return SavedPersonTile(name: person.name, onTap: () {});
                      },
                    ),
                  ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              sliver: SliverToBoxAdapter(
                child: AppPrimaryButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    );
                  },
                  text: 'Open Analytics',
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
