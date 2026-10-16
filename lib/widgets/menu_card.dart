import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../models/menu_suggestion.dart';
import '../screens/recipe_detail_screen.dart';
import '../theme.dart';

/// การ์ดเมนู 1 รายการ — ดีไซน์ใหม่สไตล์ recipe-results (พาสเทลชมพู-ฟ้า)
class MenuCard extends StatelessWidget {
  MenuCard({
    super.key,
    required this.menu,
    AppSettings? settings,
    this.initiallyExpanded = false,
    this.isFavorite = false,
    this.onToggleFavorite,
  }) : settings = settings ?? AppSettings();

  final MenuSuggestion menu;
  final AppSettings settings;
  final bool initiallyExpanded;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(menu: menu, settings: settings)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top badge & favorite button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: menu.missing.isEmpty ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          menu.missing.isEmpty ? Icons.check_circle : Icons.shopping_cart,
                          size: 14,
                          color: menu.missing.isEmpty ? Colors.green.shade700 : Colors.amber.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          menu.missing.isEmpty ? 'ทำได้ทันที' : 'ซื้อเพิ่ม ${menu.missing.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: menu.missing.isEmpty ? Colors.green.shade800 : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onToggleFavorite != null)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.pinkAccent : Colors.grey.shade400,
                      ),
                      onPressed: onToggleFavorite,
                      tooltip: isFavorite ? 'เอาออกจากเมนูโปรด' : 'บันทึกเป็นเมนูโปรด',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                menu.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
              ),
              const SizedBox(height: 6),
              Text(
                menu.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
              ),
              const SizedBox(height: 14),

              // Tags row (difficulty, time, calories)
              Row(
                children: [
                  _Tag(text: menu.difficulty, color: kPrimary),
                  const SizedBox(width: 8),
                  _Tag(icon: Icons.schedule, text: menu.time, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  if (menu.calories.isNotEmpty)
                    _Tag(icon: Icons.local_fire_department, text: menu.calories, color: Colors.orange.shade800),
                  const Spacer(),
                  // Action button "ทำเลย"
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RecipeDetailScreen(menu: menu, settings: settings)),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('ทำเลย'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({this.icon, required this.text, required this.color});
  final IconData? icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
