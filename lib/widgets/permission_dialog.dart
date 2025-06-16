import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cubits/call_request_is_opened_cubit.dart';
import '../locator_service.dart';



class PermissionDialog extends StatelessWidget {
   const PermissionDialog({super.key,required this.message});
   final String message;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Разрешение отклонено"),
      content:  Text(
        message
      ),
      actions: [
        TextButton(
          onPressed: () async{
            Navigator.pop(context);
                await openAppSettings().then((data){
                }).whenComplete((){});
                sl<CallRequestIsOpenedCubit>().changeValue(true);
            //context.read<CallRequestIsOpenedCubit>().changeValue(true);
          },
          child: const Text("Открыть настройки",style:TextStyle(color: Color.fromARGB(255, 42, 150, 131))),
        ),
      ],
    );

  }
}
