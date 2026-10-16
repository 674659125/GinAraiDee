import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../models/menu_suggestion.dart';
import '../theme.dart';

/// หน้าโหมดเตรียมปรุง (Cooking Steps Screen) — ออกแบบตามดีไซน์ cooking-steps
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.menu, required this.settings});
  final MenuSuggestion menu;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA), // Soft pastel warm cream/pink background
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: kPrimary, size: 22),
            const SizedBox(width: 6),
            const Text('โหมดเตรียมปรุง'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA), // Pastel Cyan
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                menu.calories.isNotEmpty ? menu.calories : '320 kcal',
                style: const TextStyle(color: Color(0xFF00838F), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Recipe Header info
          Text(
            menu.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
          ),
          const SizedBox(height: 6),
          Text(
            menu.description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Steps list (cooking-steps style)
          ...List.generate(menu.steps.length, (index) {
            final stepNo = index + 1;
            final totalSteps = menu.steps.length;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF), // Pastel soft pink card
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP $stepNo/$totalSteps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAD1457),
                          letterSpacing: 1.1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant, size: 16, color: kPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    menu.steps[index],
                    style: const TextStyle(fontSize: 15, color: Color(0xFF37474F), height: 1.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          // Ingredients summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8FF), // Pastel soft blue card
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFB3E5FC), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🥕 วัตถุดิบที่ใช้',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF01579B)),
                ),
                const SizedBox(height: 10),
                ...menu.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Color(0xFF0288D1)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ing, style: const TextStyle(fontSize: 14, color: Color(0xFF37474F)))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Completion button (cooking-steps style) -> saves to favorites
          FilledButton.icon(
            onPressed: () async {
              if (!settings.isFavorite(menu)) {
                await settings.toggleFavorite(menu);
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ บันทึกเมนูนี้ลงในเมนูโปรดแล้ว!')),
              );
            },
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            label: const Text('ทำเสร็จแล้ว! บันทึกไว้ในเมนูโปรด', style: TextStyle(color: Colors.white)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32), // Dark green success button as in screenshot
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
