import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PointerInterceptor(
          debug: true,
         /* child: SizedBox(
          ),*/
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => Navigator.pop(context),
            //child:
          ),
        ),
      AlertDialog(
            contentPadding: const EdgeInsets.only(left: 24, top: 8, bottom: 30),
            insetPadding: EdgeInsets.zero,
            actionsPadding: const EdgeInsets.only(bottom: 0),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(),
            title: const Text(
              'Выход',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                'Выйти из приложения?',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Да'.toUpperCase(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 42, 150, 131),
                  ),
                ),
                onPressed: () async {
                  await FlutterExitApp.exitApp(iosForceExit: true);
                },
              ),
              TextButton(
                child: Text(
                  'Нет'.toUpperCase(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 42, 150, 131),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        //),
      ],
    );
      /*GestureDetector(
      onTap: () {
        print('aaa');
      },
        child:Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: PointerInterceptor(
            child:
          ),
        ),

    )*/;
  }
}
