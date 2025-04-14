

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '';

class PdfPage extends StatelessWidget {
   PdfPage({super.key,required this.path});
  String path;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PDFView(
          filePath:path),
      ),
    );
  }
}
