

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:kdrc_flutter/widgets/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../cubits/phone_cubit.dart';
import '../cubits/settings_cubit/settings_cubit.dart';
import '../cubits/settings_cubit/settings_state.dart';
import '../utils/utils.dart';

class CallButton extends StatelessWidget {
  const CallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<PhoneCubit, bool>(
      builder: (context, phoneState) {
        if (phoneState) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context1, state) {
              if (state.isCalling) {
                return PointerInterceptor(
                  intercepting: true,
                  child: FloatingActionButton(
                    heroTag: 'fab call',
                    backgroundColor: Colors.grey[50],
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.call,
                      color: Color.fromARGB(255, 247, 176, 116),
                      size: 36,
                    ),
                    onPressed: () async {
                      if (Platform.isIOS) {
                        final status = await Permission.contacts
                            .status;
                        if (status == PermissionStatus.granted) {
                          bool? res =
                          await FlutterPhoneDirectCaller.callNumber(
                            '79532602744',
                          );
                          return;
                        }
                        else if(status==PermissionStatus.permanentlyDenied){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const PermissionDialog(message: "Включите разрешение \"Контакты\" в настройках приложения.",);
                            },
                          );
                          return;
                        }else if (status.isDenied) {
                          final status1 = await Permission.contacts
                              .request();
                          if (status1.isGranted) {
                            bool? res =
                            await FlutterPhoneDirectCaller.callNumber(
                              '79532602744',
                            );

                          }
                        } else {
                          log("Permission denied");
                        }


                        /*final Uri phoneUri = Uri(scheme: 'tel', path: '79210779641');
                              if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri);
                              } else {
                                throw 'Не удалось выполнить звонок на номер 79210779641';
                              }*/
                      } else {
                        PermissionStatus status =
                        await Permission.phone.status;

                        if (status.isGranted) {
                          if (context.mounted) {
                            Utils.showCallDialog(context);
                          }
                        } else if (status.isPermanentlyDenied) {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const PermissionDialog(message: "Чтобы включить разрешение на совершение звонков с телефона, перейдите в настройки приложения и включите его вручную.",);
                              },
                            );
                          }
                        } else if (status.isDenied) {
                          final status1 = await Permission.phone
                              .request();
                          if (status1.isGranted) {
                            if (context.mounted) {
                              Utils.showCallDialog(context);
                            }
                          }
                        } else {
                          log("Permission denied");
                        }
                      }
                    },
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
