import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:files_shared_app/models/pdf_file.dart';
import 'package:files_shared_app/enviroment.dart';

class ApiService {
  // Cambia por tu backend

  Future<List<PdfFile>> fetchPdfFiles() async {
    final response = await http.get(Uri.parse('$serverUrl/files/get'));
    print(response.toString());

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Acceder directamente a 'data' que es la lista
      List<dynamic> data = jsonResponse['data'];

      return data.map((item) => PdfFile.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar archivos PDF');
      print('Error al cargar archivos PDF');
    }
  }
}
