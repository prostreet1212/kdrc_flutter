

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class PdfPage extends StatelessWidget {
   const PdfPage({super.key,required this.path});
   final String path;

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
