import 'package:flutter/material.dart';
import '../models/qr_item.dart';

class QRCard extends StatelessWidget {
  final QRItem item;

  const QRCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Icon(item.type == 'scan' ? Icons.qr_code_scanner : Icons.qr_code),
        title: Text(item.content),
        subtitle: Text(item.createdAt.toString()),
      ),
    );
  }
}
