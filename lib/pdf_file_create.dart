import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFCreator {
  Future<void> createPDF(Uint8List imageBytes) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );
    try{

      // Get the application's document directory
      final directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/drawing_$timestamp.pdf';

      // Save the PDF file
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      print('PDF saved to: $filePath');
      

    }catch(e){
      print('Error saving PDF: $e');
    }
  }
}
