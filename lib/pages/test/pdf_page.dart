

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '';

class PdfPage extends StatelessWidget {
  const PdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PDFView(
        filePath:'https://kdrc.ru/wp-content/uploads/2025/01/%D0%98%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F-%D0%B2-%D0%A3%D1%81%D1%82%D0%B0%D0%B2-%D0%BE%D1%82-16.01.2025.pdf'),
    );
  }
}
