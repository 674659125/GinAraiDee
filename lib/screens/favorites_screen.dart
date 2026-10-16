import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../widgets/menu_card.dart';

/// หน้า "เมนูโปรด" — แสดงรายการเมนูที่ผู้ใช้บันทึกไว้
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final favorites = settings.favorites;
        return Scaffold(
          appBar: AppBar(title: const Text('เมนูโปรด')),
          body: favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'ยังไม่มีเมนูโปรด',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'กดรูปหัวใจที่การ์ดเมนู เพื่อบันทึกเก็บไว้ดูทีหลังโดยไม่ต้องถาม AI ใหม่',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'เมนูโปรดทั้งหมด ${favorites.length} รายการ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...favorites.map(
                      (menu) => MenuCard(
                        menu: menu,
                        settings: settings,
                        isFavorite: true,
                        onToggleFavorite: () => settings.toggleFavorite(menu),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
