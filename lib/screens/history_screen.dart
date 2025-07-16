import 'package:flutter/material.dart';
import '../models/qr_item.dart';
import '../services/db_service.dart';
import '../services/folder_service.dart';
import '../widgets/bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QRItem> _items = [];
  String _selectedFolder = 'All';
  List<String> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
    _loadHistory();
  }

  Future<void> _loadFolders() async {
    final list = await FolderService().getFolders();
    setState(() {
      _folders = ['All', ...list];
    });
  }

  Future<void> _loadHistory() async {
    List<QRItem> items;
    if (_selectedFolder == 'All') {
      items = await DBService().getAllQR();
    } else {
      items = await DBService().getQRByFolder(_selectedFolder);
    }
    setState(() => _items = items);
  }


  Future<void> _clearHistory() async {
    await DBService().deleteAllQR();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete),
          ),
          DropdownButton<String>(
            value: _selectedFolder,
            items: _folders
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) async {
              if (val != null) {
                setState(() => _selectedFolder = val);
                _loadHistory();
              }
            },
          ),

        ],
      ),
      bottomNavigationBar: const BottomNav(selectedIndex: 2),
      body: _items.isEmpty
          ? const Center(child: Text('No history found'))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, index) {
          final item = _items[index];
          return ListTile(
            leading: Icon(item.type == 'scan' ? Icons.qr_code_scanner : Icons.qr_code),
            title: Text(item.content),
            subtitle: Text(item.createdAt.toString()),
          );
        },
      ),
    );
  }
}
