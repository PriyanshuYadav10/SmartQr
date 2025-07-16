import 'package:shared_preferences/shared_preferences.dart';

class FolderService {
  static const _key = 'qr_folders';

  Future<List<String>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? ['General'];
  }

  Future<void> addFolder(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFolders();
    if (!list.contains(name)) {
      list.add(name);
      await prefs.setStringList(_key, list);
    }
  }

  Future<void> deleteFolder(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFolders();
    list.remove(name);
    await prefs.setStringList(_key, list);
  }
}
