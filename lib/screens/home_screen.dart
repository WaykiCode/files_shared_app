import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pdf_file.dart';
import 'pdf_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<PdfFile>> futurePdfFiles;

  @override
  void initState() {
    super.initState();
    futurePdfFiles = apiService.fetchPdfFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archivos PDF')),
      body: FutureBuilder<List<PdfFile>>(
        future: futurePdfFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay archivos PDF'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pdf = snapshot.data![index];
              return ListTile(
                title: Text(pdf.filename),
                trailing: const Icon(Icons.picture_as_pdf),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(pdfFile: pdf),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
