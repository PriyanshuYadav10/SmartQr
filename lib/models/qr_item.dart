class QRItem {
  final int? id;
  final String content;
  final String type;
  final String? folder; // new
  final DateTime createdAt;

  QRItem({this.id, required this.content, required this.type, this.folder, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'folder': folder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QRItem.fromMap(Map<String, dynamic> map) {
    return QRItem(
      id: map['id'],
      content: map['content'],
      type: map['type'],
      folder: map['folder'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
