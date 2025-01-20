import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:files_shared_app/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/api_service.dart';
import '../models/pdf_file.dart';
import 'pdf_viewer_screen.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<PdfFile>> futurePdfFiles;
  bool isConnected = true;
  bool isOnline = true;
  List<FileSystemEntity> localFiles = [];

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    isConnected = await hasInternetConnection();
    if (isOnline) {
      _refreshPdfFiles();
    } else {
      _loadLocalFiles();
    }
  }

  Future<void> _refreshPdfFiles() async {
    if (isOnline) {
      setState(() {
        futurePdfFiles = apiService.fetchPdfFiles();
      });
    }
  }

  Future<void> _loadLocalFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files =
          dir.listSync().where((file) => file.path.endsWith('.pdf')).toList();
      setState(() {
        localFiles = files;
      });
    } catch (e) {
      showToast("Error al cargar archivos locales: $e");
    }
  }

  Future<void> _switchMode(bool value) async {
    setState(() {
      isOnline = value;
    });

    if (isOnline) {
      _refreshPdfFiles();
    } else {
      _loadLocalFiles();
    }
  }

  Future<void> _syncFiles() async {
    if (!isConnected) {
      showToast("No hay conexión a Internet para sincronizar");
      return;
    }

    setState(() {
      isOnline = false;
    });

    await _deleteLocalFiles();
    await _downloadAllFiles();
    _loadLocalFiles();

    showToast("Sincronización completada");
  }

  Future<void> _deleteLocalFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (dir.existsSync()) {
        dir.listSync().forEach((file) {
          if (file is File) {
            file.deleteSync();
          }
        });
      }
      showToast("Archivos locales eliminados correctamente");
    } catch (e) {
      showToast("Error al eliminar archivos locales: $e");
    }
  }

  Future<void> _downloadAllFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await apiService.fetchPdfFiles();

      for (var file in files) {
        final filePath = '${dir.path}/${file.filename}';
        final dio = Dio();
        await dio.download('$serverUrl/files${file.fileUrl}', filePath);
      }
      showToast("Archivos descargados correctamente");
    } catch (e) {
      showToast("Error al descargar archivos: $e");
    }
  }

  Future<String> _downloadFile(String url, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';

    if (File(filePath).existsSync()) {
      return filePath;
    }

    final dio = Dio();
    await dio.download(url, filePath);
    return filePath;
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMAS VIAL'),
        actions: [
          Row(
            children: [
              const Text("Online"),
              Switch(
                value: isOnline,
                onChanged: (value) => _switchMode(value),
              ),
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _syncFiles,
                tooltip: 'Sincronizar',
              ),
            ],
          ),
        ],
      ),
      body: isOnline
          ? RefreshIndicator(
              onRefresh: _refreshPdfFiles,
              child: FutureBuilder<List<PdfFile>>(
                future: futurePdfFiles,
                builder: (context, snapshot) {
                  if (!isConnected) {
                    return Center(child: Text('No hay conexión a Internet'));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
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
                      return _buildStorageOption(
                        context,
                        icon: Icons.picture_as_pdf,
                        color: Colors.red,
                        title: pdf.filename,
                        subtitle: 'Creado el: ${pdf.filecreate}',
                        onTap: () async {
                          final filePath = await _downloadFile(
                            '$serverUrl/files${pdf.fileUrl}',
                            pdf.filename,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                localPath: filePath,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            )
          : ListView.builder(
              itemCount: localFiles.length,
              itemBuilder: (context, index) {
                final file = localFiles[index];
                return _buildStorageOption(
                  context,
                  icon: Icons.picture_as_pdf,
                  color: Colors.red,
                  title: file.path.split('/').last,
                  subtitle: 'Archivo local',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          localPath: file.path, // Pasamos la ruta local
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildStorageOption(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
