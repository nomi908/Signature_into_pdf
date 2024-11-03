import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PDFFileManager {
  Future<List<String>> getPDFs() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory(directory.path);
    List<String> pdfFiles = [];

    // List all files in the directory and filter for PDFs
    pdfFiles = pdfDirectory
        .listSync()
        .where((item) => item is File && item.path.endsWith('.pdf'))
        .map((item) => item.path)
        .toList();

    return pdfFiles;
  }
}
