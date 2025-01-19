class PdfFile {
  final String id;
  final String filename;
  final String fileUrl;

  PdfFile({required this.id, required this.filename, required this.fileUrl});

  factory PdfFile.fromJson(Map<String, dynamic> json) {
    return PdfFile(
      id: json['p_id'].toString(),
      filename: json['p_filename'],
      fileUrl: json['p_file_url'],
    );
  }
}
