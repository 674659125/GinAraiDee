import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/ai_service.dart';
import '../data/app_settings.dart';
import '../data/gemini_client.dart';
import '../models/photo_analysis.dart';
import '../widgets/error_box.dart';
import 'ingredients_screen.dart';

/// หน้า "ถ่ายรูป" → ส่งรูปให้ AI → แสดงของที่เห็น → อนุญาตให้เพิ่ม/แก้ไข/ลบวัตถุดิบได้
class PhotoScreen extends StatefulWidget {
  PhotoScreen({super.key, required this.ai, AppSettings? settings})
      : settings = settings ?? AppSettings();
  final AiService ai;
  final AppSettings settings;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final _picker = ImagePicker();

  Uint8List? _imageBytes; // รูปที่เลือก (เป็น bytes พร้อมส่ง)
  String _mimeType = 'image/jpeg';
  bool _loading = false;
  String? _error;
  PhotoAnalysis? _result;
  List<FoundItem> _editableItems = [];

  /// เปิดกล้องหรือคลังรูป แล้วย่อรูปให้เล็กลงก่อนส่ง (ประหยัดเน็ตและโควตา)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (file == null) return; // ผู้ใช้กดยกเลิก
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _mimeType = file.mimeType ?? _guessMime(file.name);
      _result = null;
      _editableItems = [];
      _error = null;
    });
  }

  static String _guessMime(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  /// ส่งรูปไปให้ AI วิเคราะห์
  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _editableItems = [];
    });
    try {
      final result = await widget.ai.analyzePhoto(bytes, mimeType: _mimeType);
      if (!mounted) return;
      setState(() {
        _result = result;
        _editableItems = List.from(result.items);
      });
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

  /// เอาชื่อของที่แก้ไขแล้ว ไปเปิดหน้า "เมนูจากวัตถุดิบ"
  void _suggestMenus() {
    final names = _editableItems.map((e) => e.name).where((n) => n.isNotEmpty).toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IngredientsScreen(ai: widget.ai, settings: widget.settings, initialIngredients: names)),
    );
  }

  /// แสดง dialog สำหรับเพิ่มหรือแก้ไขวัตถุดิบ
  void _showItemDialog({FoundItem? item, int? index}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final amountCtrl = TextEditingController(text: item?.amount ?? '');
    final noteCtrl = TextEditingController(text: item?.note ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'เพิ่มวัตถุดิบเอง' : 'แก้ไขวัตถุดิบ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ชื่อวัตถุดิบ (เช่น ไข่ไก่)')),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'ปริมาณ (เช่น 2 ฟอง)')),
            const SizedBox(height: 10),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'หมายเหตุ/สภาพ (เช่น สด)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  if (item == null) {
                    _editableItems.add(FoundItem(name: name, amount: amountCtrl.text.trim(), note: noteCtrl.text.trim()));
                  } else {
                    _editableItems[index!] = FoundItem(name: name, amount: amountCtrl.text.trim(), note: noteCtrl.text.trim());
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeKb = _imageBytes == null ? null : (_imageBytes!.lengthInBytes / 1024).round();
    return Scaffold(
      appBar: AppBar(title: const Text('ถ่ายรูปวัตถุดิบ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- พื้นที่แสดงรูป ----
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined, size: 56, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('ยังไม่ได้เลือกรูป', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),
          if (sizeKb != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('ขนาดรูปที่จะส่ง: $sizeKb KB ($_mimeType)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('ถ่ายรูป'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('เลือกจากคลัง'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: (_imageBytes == null || _loading) ? null : _analyze,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'AI กำลังดูรูป...' : 'ให้ AI วิเคราะห์รูป'),
          ),
          const SizedBox(height: 16),
          if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          if (_error != null) ErrorBox(message: _error!, onRetry: _analyze),
          if (_result != null) ..._buildResult(_result!),
        ],
      ),
    );
  }

  List<Widget> _buildResult(PhotoAnalysis r) => [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI เห็นอะไรในรูป', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(r.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('รายการวัตถุดิบ (${_editableItems.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              onPressed: () => _showItemDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('เพิ่มวัตถุดิบ'),
            ),
          ],
        ),
        if (_editableItems.isEmpty)
          const Padding(padding: EdgeInsets.all(8), child: Text('ยังไม่มีวัตถุดิบ — กดเพิ่มด้านบน'))
        else
          ..._editableItems.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final it = entry.value;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text([it.amount, it.note].where((s) => s.isNotEmpty).join(' · ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                        onPressed: () => _showItemDialog(item: it, index: index),
                        tooltip: 'แก้ไข',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () => setState(() => _editableItems.removeAt(index)),
                        tooltip: 'ลบ',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _suggestMenus,
          icon: const Icon(Icons.restaurant_menu),
          label: Text('แนะนำเมนูจากของ ${_editableItems.length} อย่างนี้'),
        ),
      ];
}
