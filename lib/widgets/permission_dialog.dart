import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Разрешение отклонено"),
      content: Text(
        "Чтобы включить разрешение на совершение звонков с телефона, перейдите в настройки приложения и включите его вручную.",
      ),
      actions: [
        TextButton(
          onPressed: () async{
            Navigator.pop(context);
           bool result=await openAppSettings();
           print('call $result');
           //проверка на разрешение?
          },
          child: Text("Открыть настройки",style:TextStyle(color: Color.fromARGB(255, 42, 150, 131))),
        ),
      ],
    );

  }
}
