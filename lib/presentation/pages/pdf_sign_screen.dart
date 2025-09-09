import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class PdfSignatureScreen extends StatefulWidget {
  final String receptionId;
  final Uint8List? existingSignature; // если уже есть подпись

  const PdfSignatureScreen({
    required this.receptionId,
    this.existingSignature,
    super.key,
  });

  @override
  State<PdfSignatureScreen> createState() => _PdfSignatureScreenState();
}

class _PdfSignatureScreenState extends State<PdfSignatureScreen> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final signatureBytes = await _controller.toPngBytes();
      if (signatureBytes != null) {
        Navigator.pop(context, signatureBytes); // возвращаем подпись на предыдущий экран
      }
    } else {
      Navigator.pop(context); // если пустая подпись
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подпись пациента'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSignature,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text('Очистить'),
            onPressed: () => _controller.clear(),
          ),
        ],
      ),
    );
  }
}
