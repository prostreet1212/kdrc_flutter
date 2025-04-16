import 'dart:async';

import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';

import 'package:kdrc_flutter/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/background_cubit.dart';
import '../cubits/error_text_cubit.dart';
import '../cubits/inet_cubit.dart';
import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';

import '../main.dart';
import 'nested_webview_controller.dart';

@pragma('vm:entry-point')
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
      /*  nestedWebviewController.webViewController
          ?.loadRequest(Uri.parse(message.data['url']));*/
      if (sl<InetCubit>().state) {
        log('firebase :: Notification payload: ${message.data['url']}');
        nestedWebviewController!.scrollStatus = ScrollStatus.forward;
        nestedWebviewController!.webViewController
            ?.loadRequest(Uri.parse(message.data['url']));
      } else {
        nestedWebviewController!.scrollStatus = ScrollStatus.forward;
        nestedWebviewController!.webViewController
            ?.loadRequest(Uri.parse(message.data['url']));
        sl<ScrollHeightCubit>().updateScrollHeight(0);
        sl<BackgroundCubit>().changeValue(true);
        sl<ErrorTextCubit>().changeValue(false);
        nestedWebviewController!.isFirstRun = true;
        //nestedWebviewController!.isBackgroundNoInternet = true;
      }
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

    subscribeToTopic( sl<SettingsCubit>().state.isPush);

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      sl<StartCubit>().changeValue(initialMessage.data['url']);
    } /*else {
      sl<StartCubit>().changeValue(false);
    }*/
  }

  Future<void> subscribeToTopic(bool isSubscribe) async {
    if (isSubscribe) {
      await _firebaseMessaging.subscribeToTopic('all');
      print('subscribeToTopic');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('all');
      print('unsubscribeToTopic');
    }
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

  //Когда приложение открыто
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (sl<InetCubit>().state) {
      if (payload != null) {
        log('firebase :: Notification payload: $payload');
        nestedWebviewController!.scrollStatus = ScrollStatus.forward;
        nestedWebviewController!.webViewController
            ?.loadRequest(Uri.parse(payload));
      }
    } else {
      nestedWebviewController!.scrollStatus = ScrollStatus.forward;
      nestedWebviewController!.webViewController
          ?.loadRequest(Uri.parse(payload!));
      sl<ScrollHeightCubit>().updateScrollHeight(0);
      sl<BackgroundCubit>().changeValue(true);
      sl<ErrorTextCubit>().changeValue(false);
      nestedWebviewController!.isFirstRun = true;
      //nestedWebviewController!.isBackgroundNoInternet = true;
    }
  }

  // Background handler (required for background notifications)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log('firebase :: Handling a background message: ${message.messageId}');
  }

// Get device token (you can send this to your server for targeted notifications)
/* Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("Device Token: $token");
    return token;
  }*/
}
