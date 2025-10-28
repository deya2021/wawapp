import 'package:flutter/material.dart';
import '../../core/build_info/build_info.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buildInfo = BuildInfoProvider.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حول النسخة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('الإصدار:', buildInfo.version),
            _buildInfoRow('الفرع:', buildInfo.branch),
            _buildInfoRow('الكوميت:', buildInfo.commit),
            _buildInfoRow('النكهة:', buildInfo.flavor),
            _buildInfoRow('فلاتر:', buildInfo.flutter),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
