import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

class FileLoadingDialog extends StatelessWidget {
  const FileLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: EdgeInsets.only(left: 24, top: 16, bottom: 20),
        insetPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.only(bottom: 0),
        backgroundColor: Colors.grey[350],
        shape: RoundedRectangleBorder(),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            GifView.asset(
              'assets/images/loading_windows.gif',
              height: 50,
              width: 50,
              frameRate: 23,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(child: Text('Подождите, документ открывается',style: TextStyle(fontSize: 16),))
          ]),
        ),
      ),
    );
  }
}
