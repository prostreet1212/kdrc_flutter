import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';
import 'package:kdrc_flutter/pages/settings_page.dart';
import 'package:kdrc_flutter/pages/sl_copy.dart';
import 'package:kdrc_flutter/utils/utils.dart';

import '../locator_service.dart';
import '../main.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._privateConstructor();

  static final NotificationService _instance =
      NotificationService._privateConstructor();

  static NotificationService get instance => _instance;

  // Callback for handling foreground message updates (optional)
  Function(RemoteMessage)? onForegroundMessage;

  late RemoteMessage m;

  Future<void> initialize() async {
    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('firebase :: User granted permission: ${settings.authorizationStatus}');

    // Configure Local Notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('bell');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );


    /* _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (n){});*/

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('firebase :: Received a foreground message: ${message.messageId}');
      m = message;
      _showNotification(message);

      // If there's a foreground message handler, call it
      if (onForegroundMessage != null) {
        onForegroundMessage!(message);
      }
    });

    // Handle when the app is opened from a notification
    //Когда приложение свернуто
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('firebase :: Notification clicked! Message: ${message.notification?.title}');
      //_handleNotificationClick(message);
      //open(message);
      nestedWebviewController.webViewController
          ?.loadRequest(Uri.parse(message.data['url']));
    });

//Когда приложение закрыто
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      log('firebase :: Notification2 clicked! Message: ${message?.notification?.title}');
      if (message != null) {
        // Обработка уведомления, когда приложение запущено из закрытого состояния
     /*   Future.delayed(Duration(seconds: 3),(){
          nestedWebviewController.webViewController
              ?.loadRequest(Uri.parse(message.data['url']));
        });*/
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    subscribeToTopic();

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      sl<StartCubit>().changeValue(initialMessage.data['url']);
    } /*else {
      sl<StartCubit>().changeValue(false);
    }*/

  }

  Future<void> subscribeToTopic() async {
    await _firebaseMessaging.subscribeToTopic('all');
    print('subscribeToTopic');
  }

  // Show local notification
  Future<void> _showNotification(RemoteMessage message) async {
    String? imgUrl = message.notification?.android?.imageUrl;
    ByteArrayAndroidBitmap? largeIcon;
// converting image into base65 to show in notification bar
    BigPictureStyleInformation? bigPictureStyleInformation;
      try {
        // Create BigPictureStyleInformation for displaying the image
        bigPictureStyleInformation = BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String('base64Image'),
         // contentTitle: message.notification?.title,
         // summaryText: message.notification?.body,
        );
      } catch (e) {
        print('Error fetching image: $e');
      }
    //}

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
       //icon: 'bell',
      // largeIcon: largeIcon, // This sets the small image on the right side ofnotification title
      styleInformation: null,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformChannelSpecifics,
      payload: message.data['url'],
    );

    print(
        'push-уведомление: ${message.notification!.title}, ${message.notification!.body}/${message.data}');
  }

  // Handle notification click action
  Future<void> _handleNotificationClick(RemoteMessage message) async {
    log('firebase :: User tapped on notification: ${message.notification?.title}');
    // You can navigate to a specific screen using Navigator here
  }

  // Called when a notification is tapped (foreground or background)
  //Когда приложение открыто
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      log('firebase :: Notification payload: $payload');
      nestedWebviewController.webViewController
          ?.loadRequest(Uri.parse(payload));
      // Navigate or perform an action based on the payload
    }
  }

  // Background handler (required for background notifications)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log('firebase :: Handling a background message: ${message.messageId}');
  }

  // Get device token (you can send this to your server for targeted notifications)
  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("Device Token: $token");
    return token;
  }
}
