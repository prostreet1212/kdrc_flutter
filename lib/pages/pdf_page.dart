

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
        floatingActionButton: SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
            heroTag: 'fab back',
            highlightElevation: 0,
            elevation: 0,
            child: const Icon(
              Icons.keyboard_backspace,
              color: Color.fromARGB(255, 247, 176, 116),
              //color: Color.fromARGB(255, 32, 146, 131),
              size: 32,
            ),
            backgroundColor: Color.fromARGB(40, 0, 0, 0),
            shape: const CircleBorder(),
            onPressed: ()  {
              Navigator.pop(context);
            },),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      ),
    );
  }
}
