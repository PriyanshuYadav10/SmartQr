import 'package:flutter/material.dart';
import '../services/folder_service.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final FolderService _service = FolderService();
  final TextEditingController _controller = TextEditingController();
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final data = await _service.getFolders();
    setState(() => folders = data);
  }

  Future<void> _addFolder() async {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      await _service.addFolder(name);
      _controller.clear();
      _loadFolders();
    }
  }

  Future<void> _deleteFolder(String name) async {
    await _service.deleteFolder(name);
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Folders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Folder',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addFolder,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: folders.length,
              itemBuilder: (_, index) {
                final folder = folders[index];
                return ListTile(
                  title: Text(folder),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFolder(folder),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
