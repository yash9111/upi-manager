import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SavedPersonTile
    extends StatelessWidget {
  final String name;

  final VoidCallback onTap;

  const SavedPersonTile({
    super.key,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  AppColors.primary
                      .withOpacity(0.1),
              child: Text(
                name[0]
                    .toUpperCase(),
                style:
                    const TextStyle(
                  color:
                      AppColors
                          .primary,
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Text(
                name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w600,
                  fontSize: 16,
                ),
              ),
            ),

            const Icon(
              Icons.add,
              color:
                  AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}