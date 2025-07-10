

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../locator_service.dart';
import '../locator_service.dart' as di;
import '../utils/nested_webview_controller.dart';
import 'custom_toast.dart';
import 'exit_dialog.dart';

class GoBackButton extends StatelessWidget {
  const GoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(left: 24),
      child: SizedBox(
        width: 40,
        height: 40,
        child: PointerInterceptor(
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
            onPressed: () async {
              if (await sl<NestedWebviewController>().webViewController!
                  .canGoBack()) {
                sl<NestedWebviewController>().scrollStatus =
                    ScrollStatus.prev;
                sl<NestedWebviewController>().isStep = true;
                sl<NestedWebviewController>().webViewController!
                    .goBack();
              } else {
                showDialog(
                  context: context,
                  builder: (context) => const ExitDialog(),
                );
               /* di.sl<NestedWebviewController>().fToast.showToast(
                  child: const CustomToast(
                    message:
                    // 'Это начальная странцица',
                    'Это начальная страница. Дальнейший переход не требуется',
                  ),
                  toastDuration: const Duration(seconds: 2),
                  gravity: ToastGravity.BOTTOM,
                );*/
              }
            },),
        ),
      ),
    );
  }
}
