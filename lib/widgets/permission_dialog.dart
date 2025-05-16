import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cubits/call_request_is_opened_cubit.dart';



class PermissionDialog extends StatefulWidget {
   const PermissionDialog({super.key});


  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog>  {



  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();

  }





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
                await openAppSettings().then((data){
                  print('data ${data}');
                }).whenComplete((){});
            context.read<CallRequestIsOpenedCubit>().changeValue(true);
           print('call ${context.read<CallRequestIsOpenedCubit>().state}');
           //проверка на разрешение?
          },
          child: Text("Открыть настройки",style:TextStyle(color: Color.fromARGB(255, 42, 150, 131))),
        ),
      ],
    );

  }
}
