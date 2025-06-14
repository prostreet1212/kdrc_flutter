import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/phone_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cubits/settings_cubit/settings_state.dart';
import '../locator_service.dart';
import '../utils/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});


  @override
  State<SettingsPage> createState() => _SettingsPageState();
}



class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {

  bool isPushSettingsOpen=false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
     if(isPushSettingsOpen){
        isPushSettingsOpen=false;
        bool pushPermission=await sl<NotificationService>().checkPushPermission();
        if(pushPermission){
          sl<SettingsCubit>().updateIsPush(true);
          sl<NotificationService>().subscribeToTopic(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(200, 56),
            child: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Padding(
                padding: EdgeInsets.only(top: 6),
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
              BlocBuilder<PhoneCubit, bool>(builder: (context, phoneState) {
                if (phoneState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 16, right: 6),
                        //leading: SizedBox(width: 50,),
                        title: const Text('Кнопка "Звонок"'),
                        subtitle: Text(
                          'Отображать кнопку звонка на экране',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        trailing: BlocBuilder<SettingsCubit, SettingsState>(
                          buildWhen:(prev,next){
                            return prev.isCalling!=next.isCalling;
                          },
                            builder: (context, settingsState) {
                          return Checkbox(
                              activeColor: Colors.teal,
                              value: settingsState.isCalling,
                              onChanged: (value)async {
                                await sl<SettingsCubit>().updateIsCalling(value!);
                              });
                        }),
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey[400],
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 6),
                  //leading: SizedBox(width: 50,),
                  title: const Text('Push-уведомления'),
                  subtitle: Text(
                    'Отправлять push-уведомления',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  trailing: BlocBuilder<SettingsCubit, SettingsState>(
                      buildWhen:(prev,next){
                        return prev.isPush!=next.isPush;
                      },
                      builder: (context, settingsState) {
                    return Checkbox(
                        activeColor: Colors.teal,
                        value: settingsState.isPush,
                        onChanged: (value) async{
                        if(value==true){
                          bool pushPermission=await sl<NotificationService>().checkPushPermission();
                          if(pushPermission){
                            sl<SettingsCubit>().updateIsPush(value!);
                            sl<NotificationService>().subscribeToTopic(value);
                          }else{
                            if(context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Не удалось получить разрешение \"Уведомления\", перейдите в настройки приложения и включите его вручную.",
                                ),
                                duration: const Duration(milliseconds: 3500),
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'Открыть настройки',
                                  onPressed: () async{
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    await openAppSettings().then((v){
                                      isPushSettingsOpen=true;
                                    })
                                        .whenComplete(
                                            (){
                                              isPushSettingsOpen=true;
                                            });
                                  },
                                  textColor: const Color.fromARGB(255, 247, 176, 116),),
                              ),
                            );
                            }
                          }
                        }else{
                          sl<SettingsCubit>().updateIsPush(value!);
                          sl<NotificationService>().subscribeToTopic(value);
                        }

                        });
                  })),
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
                  child: const Text(
                    'ОК',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          )),
    );
  }
}
