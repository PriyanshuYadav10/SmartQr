import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../models/qr_item.dart';
import '../services/db_service.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleScan(String code, BuildContext context) async {
    await DBService().insertQR(
      QRItem(content: code, type: 'scan', createdAt: DateTime.now()),
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _buildSmartActionSheet(context, code),
    );
  }

  Widget _buildSmartActionSheet(BuildContext context, String content) {
    final Uri? uri = Uri.tryParse(content);

    if (uri != null && uri.scheme.startsWith('http')) {
      return _buildSheetTile(
        context,
        icon: Icons.link,
        label: 'Open Link',
        onTap: () => launchUrl(uri),
      );
    } else if (uri != null && uri.scheme == 'mailto') {
      return _buildSheetTile(
        context,
        icon: Icons.email,
        label: 'Send Email',
        onTap: () => launchUrl(uri),
      );
    } else if (RegExp(r'^\+?[0-9]{7,}$').hasMatch(content)) {
      return _buildSheetTile(
        context,
        icon: Icons.phone,
        label: 'Call Number',
        onTap: () => launchUrl(Uri.parse("tel:$content")),
      );
    } else if (content.toLowerCase().startsWith("wifi:")) {
      return _buildSheetTile(
        context,
        icon: Icons.wifi,
        label: 'Connect Wi-Fi',
        onTap: () => Clipboard.setData(ClipboardData(text: content)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Wi-Fi QR copied! Please connect manually.")));
        }),
      );
    } else {
      return _buildSheetTile(
        context,
        icon: Icons.copy,
        label: 'Copy Text',
        onTap: () => Clipboard.setData(ClipboardData(text: content)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Copied to clipboard")));
        }),
      );
    }
  }

  Widget _buildSheetTile(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(label, style: const TextStyle(fontSize: 18)),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartQR – Scan')),
      bottomNavigationBar: const BottomNav(selectedIndex: 0),
      body: MobileScanner(
        onDetect: (barcode) {
          final code = barcode.raw;
          if (code != null) {
            _handleScan(code.toString(), context);
          }
        },
      ),
    );
  }
}
