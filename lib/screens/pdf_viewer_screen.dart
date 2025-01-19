import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import 'package:files_shared_app/models/pdf_file.dart';
import 'package:files_shared_app/enviroment.dart';

class PdfViewerScreen extends StatefulWidget {
  final PdfFile pdfFile;

  const PdfViewerScreen({Key? key, required this.pdfFile}) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localFilePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.pdfFile.filename}');

      if (!file.existsSync()) {
        Dio dio = Dio();
        final String fullUrl = '$serverUrl/files${widget.pdfFile.fileUrl}';
        await dio.download(fullUrl, file.path);
      }

      setState(() {
        localFilePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("Error descargando el PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pdfFile.filename)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localFilePath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            ),
    );
  }
}
