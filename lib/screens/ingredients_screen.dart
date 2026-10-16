import 'package:flutter/material.dart';

import '../data/ai_service.dart';
import '../data/app_settings.dart';
import '../data/gemini_client.dart';
import '../models/menu_suggestion.dart';
import '../theme.dart';
import '../widgets/error_box.dart';
import '../widgets/menu_card.dart';

/// หน้า "พิมพ์วัตถุดิบ" — ดีไซน์ใหม่สไตล์ ingredient-scanner (พาสเทลชมพู-ฟ้า)
class IngredientsScreen extends StatefulWidget {
  IngredientsScreen({
    super.key,
    required this.ai,
    AppSettings? settings,
    this.initialIngredients = const [],
  }) : settings = settings ?? AppSettings();

  final AiService ai;
  final AppSettings settings;
  final List<String> initialIngredients;

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final _inputCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();
  late final List<String> _ingredients = [...widget.initialIngredients];

  bool _loading = false;
  String? _error;
  MenuResult? _result;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final items = _inputCtrl.text
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !_ingredients.contains(e));
    setState(() => _ingredients.addAll(items));
    _inputCtrl.clear();
  }

  Future<void> _ask() async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ใส่วัตถุดิบอย่างน้อย 1 อย่างก่อน')));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await widget.ai.suggestMenus(_ingredients, extra: _extraCtrl.text);
      if (!mounted) return;
      setState(() => _result = result);
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'อ่านคำตอบของ AI ไม่ได้: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('เครื่องสแกนวัตถุดิบ 🔍')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- Input Container (Scanner style) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ตรวจพบวัตถุดิบแล้ว (${_ingredients.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => _ingredients.clear()),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                        label: const Text('รีเซ็ต', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_ingredients.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F6FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'ยังไม่มีวัตถุดิบ — พิมพ์ด้านล่างหรือกดเพิ่ม',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _ingredients
                          .map((item) => InputChip(
                                label: Text(item, style: const TextStyle(color: Color(0xFFAD1457), fontWeight: FontWeight.w600)),
                                backgroundColor: const Color(0xFFFFECEF),
                                deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFFAD1457)),
                                onDeleted: () => setState(() => _ingredients.remove(item)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _inputCtrl,
                    decoration: InputDecoration(
                      labelText: 'พิมพ์เพิ่มวัตถุดิบ',
                      hintText: 'เช่น ไข่ไก่, หมูสับ, กะเพรา',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle, color: kPrimary),
                        onPressed: _addIngredient,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addIngredient(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _extraCtrl,
                    decoration: const InputDecoration(
                      labelText: 'เงื่อนไขเพิ่มเติม (ไม่บังคับ)',
                      hintText: 'เช่น ไม่กินเผ็ด, ทำใน 15 นาที',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Action Button (ingredient-scanner style) ---
            FilledButton.icon(
              onPressed: _loading ? null : _ask,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(_loading ? 'AI กำลังคิดเมนู...' : 'ให้ AI แนะนำเมนู', style: const TextStyle(color: Colors.white)),
              style: FilledButton.styleFrom(
                backgroundColor: kPrimary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 2,
                shadowColor: kPrimary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: kPrimary),
                ),
              ),
            if (_error != null) ErrorBox(message: _error!, onRetry: _ask),
            if (_result != null) ..._buildResult(_result!),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResult(MenuResult r) => [
        if (r.summary.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(r.summary, style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF01579B), height: 1.4)),
          ),
        Text('เมนูแนะนำ ${r.menus.length} รายการ', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...r.menus.asMap().entries.map((e) => MenuCard(
              menu: e.value,
              settings: widget.settings,
              initiallyExpanded: e.key == 0,
              isFavorite: widget.settings.isFavorite(e.value),
              onToggleFavorite: () => widget.settings.toggleFavorite(e.value),
            )),
      ];
}
