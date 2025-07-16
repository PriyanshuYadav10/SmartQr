import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/qr_item.dart';
import '../services/db_service.dart';
import '../services/folder_service.dart';
import '../services/template_service.dart';
import '../models/qr_template.dart';
import '../widgets/bottom_nav.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _controller = TextEditingController();
  String qrData = '';
  Color _fgColor = Colors.black;
  Color _bgColor = Colors.white;
  File? _logoFile;
  String _selectedFolder = 'General';
  List<String> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadTemplate();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final f = await FolderService().getFolders();
    setState(() => _folders = f);
  }

  final TemplateService _templateService = TemplateService();

  void _generateQR() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      qrData = text;
    });

    final item = QRItem(
      content: text,
      type: 'generate',
      folder: _selectedFolder,
      createdAt: DateTime.now(),
    );

    await DBService().insertQR(item);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }

  void _pickColor(bool isForeground) async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isForeground ? 'Select Foreground Color' : 'Select Background Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: isForeground ? _fgColor : _bgColor,
              onColorChanged: (color) {
                setState(() {
                  if (isForeground) _fgColor = color;
                  else _bgColor = color;
                });
              },
              enableAlpha: false,
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))],
        );
      },
    );
  }

  Future<void> _saveTemplate() async {
    final template = QRTemplate(
      foregroundColor: _fgColor,
      backgroundColor: _bgColor,
      logoPath: _logoFile?.path,
    );
    await _templateService.saveTemplate(template);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template Saved')));
  }

  Future<void> _loadTemplate() async {
    final template = await _templateService.getTemplate();
    if (template != null) {
      setState(() {
        _fgColor = template.foregroundColor;
        _bgColor = template.backgroundColor;
        if (template.logoPath != null) _logoFile = File(template.logoPath!);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code')),
      bottomNavigationBar: const BottomNav(selectedIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text/link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickColor(true),
                  icon: const Icon(Icons.color_lens),
                  label: const Text("FG Color"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickColor(false),
                  icon: const Icon(Icons.format_color_fill),
                  label: const Text("BG Color"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.image),
                  label: const Text("Logo"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedFolder,
              isExpanded: true,
              items: _folders
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedFolder = val);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _generateQR,
              child: const Text('Generate QR'),
            ),
            const SizedBox(height: 20),
            if (qrData.isNotEmpty)
              Center(
                child: QrImageView(
                  data: qrData,
                  size: 220,
                  backgroundColor: _bgColor,
                  foregroundColor: _fgColor,
                  embeddedImage:
                  _logoFile != null ? FileImage(_logoFile!) : null,
                  embeddedImageStyle: QrEmbeddedImageStyle(size: const Size(50, 50)),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.save),
              label: const Text("Save Template"),
            ),
          ],
        ),
      ),
    );
  }
}
