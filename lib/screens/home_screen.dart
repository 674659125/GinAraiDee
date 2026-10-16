import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../theme.dart';
import 'favorites_screen.dart';
import 'ingredients_screen.dart';
import 'photo_screen.dart';
import 'settings_screen.dart';

/// หน้าแรก — เลือกว่าจะถาม AI ด้วย "ข้อความ" หรือ "รูปภาพ"
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu, size: 26),
              SizedBox(width: 8),
              Text('กินไรดี'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'ตั้งค่า',
              onPressed: () => _openSettings(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!settings.ready) _SetupBanner(onTap: () => _openSettings(context)),
            if (settings.demoMode) const _DemoBanner(),
            const SizedBox(height: 4),
            // --- Hero Welcome Banner ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF00B0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🍳 ผู้ช่วยครัวอัจฉริยะ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'มีวัตถุดิบอะไรในตู้เย็น? ให้ AI ช่วยคิดเมนูแสนอร่อยพร้อมแคลอรีให้คุณได้ทันที',
                    style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'เลือกวิธีค้นหาเมนู',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.edit_note_rounded,
              color: kPrimary,
              title: 'พิมพ์วัตถุดิบที่มี',
              subtitle: 'เช่น ไข่, หมูสับ, กระเทียม → AI แนะนำเมนูพร้อมวิธีทำและแคลอรี',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IngredientsScreen(ai: settings.aiService, settings: settings)),
              ),
            ),
            _FeatureCard(
              icon: Icons.camera_alt_rounded,
              color: kAccent,
              title: 'ถ่ายรูปวัตถุดิบ',
              subtitle: 'ถ่ายรูปหรือเลือกภาพวัตถุดิบ ให้ AI วิเคราะห์แล้วต่อยอดเป็นเมนู',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoScreen(ai: settings.aiService, settings: settings)),
              ),
            ),
            _FeatureCard(
              icon: Icons.favorite_rounded,
              color: Colors.pinkAccent,
              title: 'เมนูโปรด (${settings.favorites.length})',
              subtitle: 'รวมเมนูเด็ดที่คุณบันทึกไว้ เปิดดูได้ตลอดเวลา',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FavoritesScreen(settings: settings)),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'โมเดล: ${settings.demoMode ? "โหมดสาธิต" : "Gemini"} · วิชา 5534408',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SettingsScreen(settings: settings)),
      );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      );
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: MaterialBanner(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Icon(Icons.key_rounded, color: Colors.brown),
          content: const Text('ยังไม่ได้ใส่ Gemini API key — ใส่ key หรือเปิดโหมดสาธิตก่อนใช้งาน'),
          actions: [TextButton(onPressed: onTap, child: const Text('ไปตั้งค่า', style: TextStyle(fontWeight: FontWeight.bold)))],
        ),
      );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.science_rounded, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text('โหมดสาธิต: คำตอบเป็นข้อมูลจำลอง ไม่ได้ส่งไป Gemini จริง', style: TextStyle(fontSize: 13, color: Colors.blueAccent))),
          ],
        ),
      );
}
