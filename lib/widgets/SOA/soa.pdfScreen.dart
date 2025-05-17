import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart';

class PdfViewerScreen extends StatelessWidget {
  final String path;

  const PdfViewerScreen({super.key, required this.path});

  Future<bool> _validatePdfFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        if (length > 100) return true;
        throw Exception(S.current.pdfFileTooSmall);
      } else {
        throw Exception(S.current.pdfFileNotFound);
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pdfViewerTitle)),
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
                  Text(l10n.failedToLoadPdf),
                  Text(
                    "${l10n.error}: ${snapshot.error ?? l10n.invalidOrEmptyFile}",
                    textAlign: TextAlign.center,
                  ),
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