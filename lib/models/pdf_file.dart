class PdfFile {
  final String id;
  final String filename;
  final String filecreate;
  final String fileUrl;

  PdfFile(
      {required this.id,
      required this.filename,
      required this.filecreate,
      required this.fileUrl});

  factory PdfFile.fromJson(Map<String, dynamic> json) {
    return PdfFile(
      id: json['p_id'].toString(),
      filename: json['p_filename'],
      filecreate: json['p_create_at'],
      fileUrl: json['p_file_url'],
    );
  }
}
