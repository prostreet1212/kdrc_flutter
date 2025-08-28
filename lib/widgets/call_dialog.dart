import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CallDialog extends StatelessWidget {
  const CallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Stack(
            children: [
              PointerInterceptor(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) => Navigator.pop(context),
                ),
              ),
              AlertDialog(
                contentPadding: const EdgeInsets.only(
                  left: 24,
                  top: 8,
                  bottom: 30,
                ),
                insetPadding: EdgeInsets.zero,
                actionsPadding: const EdgeInsets.only(bottom: 0),
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
                title: const Text(
                  'Приёмная',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    'Позвонить в приёмную?',
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
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      if (Platform.isAndroid) {
                        await FlutterDirectCall.makeDirectCall("+78183730050");
                        /* final Uri _url = Uri.parse('tel:+7-81837-300-50');
                        await launchUrl(
                          _url,
                          mode: LaunchMode.platformDefault,
                        );*/
                      } else {
                        await FlutterPhoneDirectCaller.callNumber(
                          '78183730050',
                        );
                      }
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
            ],
          )
        : AlertDialog(
            contentPadding: const EdgeInsets.only(left: 24, top: 8, bottom: 30),
            insetPadding: EdgeInsets.zero,
            actionsPadding: const EdgeInsets.only(bottom: 0),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(),
            title: const Text(
              'Приёмная',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                'Позвонить в приёмную?',
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
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (Platform.isAndroid) {
                    await FlutterDirectCall.makeDirectCall("+78183730050");
                    /* final Uri _url = Uri.parse('tel:+7-81837-300-50');
                        await launchUrl(
                          _url,
                          mode: LaunchMode.platformDefault,
                        );*/
                  } else {
                    await FlutterPhoneDirectCaller.callNumber('78183730050');
                  }
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
          );
  }
}
