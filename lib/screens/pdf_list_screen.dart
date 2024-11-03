
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:sigo_converter/pdf_file_manager.dart';

class PDFListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved PDFs')),
      body: FutureBuilder<List<String>>(
        future: PDFFileManager().getPDFs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No PDFs found.'));
          } else {
            // Display the list of PDFs
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pdfPath = snapshot.data![index];
                return ListTile(
                  title: Text('PDF ${index + 1}'),
                  subtitle: Text(pdfPath),
                  onTap: () async {

                    final result = await OpenFile.open(pdfPath);
                    if (result.message != 'File opened successfully.') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open PDF: ${result.message}')),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
