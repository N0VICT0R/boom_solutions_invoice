import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String path;

  const PdfViewerScreen({super.key, required this.path});

  Future<bool> _validatePdfFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        if (length > 100) return true;
        throw Exception("PDF file is too small or corrupted.");
      } else {
        throw Exception("PDF file does not exist.");
      }
    } catch (e) {
     
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: FutureBuilder<bool>(
        future: _validatePdfFile(path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !(snapshot.data ?? false)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  const Text("Failed to load PDF"),
                  Text("Error: ${snapshot.error ?? 'Invalid or empty file'}"),
                ],
              ),
            );
          }
          // If the file is valid, display the PDF using Syncfusion
          return SfPdfViewer.file(File(path));
        },
      ),
    );
  }
}
