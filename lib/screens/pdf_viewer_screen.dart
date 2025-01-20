import 'package:files_shared_app/models/pdf_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final String? localPath; // Ruta del archivo local (si es Offline)

  const PdfViewerScreen({super.key, this.localPath});

  @override
  Widget build(BuildContext context) {
    // Determinar la ruta del archivo a visualizar

    if (localPath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Visualizador PDF'),
        ),
        body: const Center(
          child: Text('No se pudo cargar el archivo PDF'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador PDF'),
      ),
      body: PDFView(
        filePath: localPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
