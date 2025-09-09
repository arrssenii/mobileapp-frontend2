import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfBytes; // PDF в виде байтов

  const PdfViewerScreen({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Просмотр PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Здесь можно обновить PDF, если нужно
            },
          ),
        ],
      ),
      body: SfPdfViewer.memory(
        pdfBytes,
        canShowScrollHead: true,
        canShowPaginationDialog: true,
      ),
    );
  }
}
