


import 'package:flutter/material.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:kdrc_flutter/widgets/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class CallDialog extends StatelessWidget {
  const CallDialog({super.key,required this.callRequestResult});
  final bool callRequestResult;

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      contentPadding: EdgeInsets.only(left: 24, top: 8, bottom: 30),
      insetPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.only(bottom: 0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(),
      title: Text(
        'Приёмная',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Text(
          'Позвонить в приёмную?',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Да'.toUpperCase(),
            style: TextStyle(color: Color.fromARGB(255, 42, 150, 131)),
          ),
          onPressed: () async {
            PermissionStatus status = await Permission.phone.status;
            if (status.isGranted) {
              if(context.mounted){
                Navigator.pop(context);
              }

              FlutterDirectCall.makeDirectCall("+79210779641");
            } else if (status.isPermanentlyDenied) {
              //await Permission.phone.request();
              if(context.mounted) {
                Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context){
                    //Navigator.pop(context);
                    return PermissionDialog(callRequestResult: callRequestResult,);
                  });
              }
              //openAppSettings();
            } else if (status.isDenied) {
    if(context.mounted){
              Navigator.pop(context);
    }
              final status1 = await Permission.phone.request();
              if(status1.isGranted){
                await FlutterDirectCall.makeDirectCall("+79210779641");
              }
            } else {
              print("Permission denied");
            }
            /* final Uri _url = Uri.parse('tel:+7-81837-300-50');
                      await launchUrl(
                        _url,
                        mode: LaunchMode.platformDefault,
                      );*/
          },
        ),
        TextButton(
          child: Text('Нет'.toUpperCase(),
              style: TextStyle(color: Color.fromARGB(255, 42, 150, 131))),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],

    );
  }
}
