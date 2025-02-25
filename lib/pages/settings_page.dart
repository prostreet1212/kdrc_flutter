import 'package:flutter/material.dart';
import 'package:kdrc_flutter/cubits/settings_cubit.dart';

import '../locator_service.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPush = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(200, 56),
            child: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'НАСТРОЙКИ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 19, 124, 179)),
                ),
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.only( left: 16, right: 6),
                //leading: SizedBox(width: 50,),
                title: Text('Кнопка "Звонок"'),
                subtitle: Text(
                  'Отображать кнопку звонка на экране',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                trailing: Checkbox(
                    activeColor: Colors.teal,
                    //value: settingPrefs.getBool('isCalling')??true,
                    value: sl<SettingsCubit>().state,
                    onChanged: (value) {
                      setState(() {
                        sl<SettingsCubit>().changeCalling(value!);
                      });
                    }),
              ),
              Container(
                height: 1,
                color: Colors.grey[400],
              ),
              ListTile(
                contentPadding:
                EdgeInsets.only( left: 16, right: 6),
                //leading: SizedBox(width: 50,),
                title: Text('Push-уведомления'),
                subtitle: Text(
                  'Отправлять push-уведомления',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                trailing: Checkbox(
                    activeColor: Colors.teal,
                    value: isPush,
                    onChanged: (value) {
                      setState(() {
                        isPush = value!;
                      });
                    }),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[350],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: Text('ОК',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                    onPressed: (){
                Navigator.pop(context);
                    },
                   ),
              )
            ],
          )),
    );
  }
}
