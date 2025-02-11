import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Разрешение отклонено навсегда"),
      content: Text(
        "Чтобы включить разрешение на использование телефона, перейдите в настройки приложения и включите его вручную.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: Text("Открыть настройки"),
        ),
      ],
    );

  }
}
