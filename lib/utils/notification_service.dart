import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';

import '../cubits/background_cubit.dart';
import '../cubits/error_text_cubit.dart';
import '../cubits/inet_cubit.dart';
import '../cubits/loading_cubit.dart';
import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';

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

  Future<bool> checkPushPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> initialize() async {
    // Request permissions for iOS
    //спрашивать разрешенение только при 1-м запуске
    if (sl<SettingsCubit>().state.isFirstPushRequest == true) {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true);
      log(
        'firebase :: User granted permission: ${settings.authorizationStatus}',
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await sl<SettingsCubit>().updateIsPush(true);
      } else {
        await sl<SettingsCubit>().updateIsPush(false);
      }
      await sl<SettingsCubit>().updateIsFirstPushRequest(false);
    }

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
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)  async {
      print(
        'firebase :: Notification clicked! Message: ${message.notification?.title}',
      );
      //_handleNotificationClick(message);
      /*  nestedWebviewController.webViewController
          ?.loadRequest(Uri.parse(message.data['url']));*/
      if (sl<InetCubit>().state) {
        print('firebase :: Notification payload: ${message.data['url']}');
        sl<LoadingCubit>().changeValue(true);
        sl<NestedWebviewController>().scrollStatus = ScrollStatus.forward;
        //sl<NestedWebviewController>().webViewController=await sl<NestedWebviewController>().controllerCompleter.future;

       /* while (sl<NestedWebviewController>().webViewController == null) {
           await Future.delayed(const Duration(milliseconds: 50));
          print('WebViewController is still null, waiting...');
        }*/
        sl<NestedWebviewController>().webViewController = await  sl<NestedWebviewController>().controllerCompleter.future;
        print('is crashed: ${sl<NestedWebviewController>().isCrashed}');
        if(sl<NestedWebviewController>().isCrashed==true){
          sl<NestedWebviewController>().isCrashed=false;
          await sl<NestedWebviewController>().webViewController!.reload();
          await sl<NestedWebviewController>().webViewController!.loadUrl(
            urlRequest: URLRequest(url: WebUri(message.data['url'])),
          );
        }else{
          sl<NestedWebviewController>().webViewController!.loadUrl(
            urlRequest: URLRequest(url: WebUri(message.data['url'])),
          );
        }







        //?.loadRequest(Uri.parse(message.data['url']));
      } else {
        sl<NestedWebviewController>().scrollStatus = ScrollStatus.forward;
        sl<NestedWebviewController>().webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(message.data['url'])),
        );
        //?.loadRequest(Uri.parse(message.data['url']));
        sl<ScrollHeightCubit>().updateScrollHeight(0);
        sl<BackgroundCubit>().changeValue(true);
        sl<ErrorTextCubit>().changeValue(false);
        //nestedWebviewController!.isFirstRun = true;
        //nestedWebviewController!.isBackgroundNoInternet = true;
      }
    });

    //Когда приложение закрыто
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      print(
        'firebase :: Notification2 clicked! Message: ${message?.notification?.title}',
      );
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

    subscribeToTopic(sl<SettingsCubit>().state.isPush);

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      sl<StartCubit>().changeValue(initialMessage.data['url']);
    }
  }

  Future<void> subscribeToTopic(bool isSubscribe) async {
    if (isSubscribe) {
      await _firebaseMessaging.subscribeToTopic('all');
      log('subscribeToTopic');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('all');
      log('unsubscribeToTopic');
    }
  }

  // Show local notification
  Future<void> _showNotification(RemoteMessage message) async {
    //String? imgUrl = message.notification?.android?.imageUrl;
    //ByteArrayAndroidBitmap? largeIcon;
    // converting image into base65 to show in notification bar
    /*  BigPictureStyleInformation? bigPictureStyleInformation;
    try {
      // Create BigPictureStyleInformation for displaying the image
      bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String('base64Image'),
        // contentTitle: message.notification?.title,
        // summaryText: message.notification?.body,
      );
    } catch (e) {
      print('Error fetching image: $e');
    }*/
    //}

    AndroidNotificationDetails
    androidPlatformChannelSpecifics = const AndroidNotificationDetails(
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

    log(
      'push-уведомление: ${message.notification!.title}, ${message.notification!.body}/${message.data}',
    );
  }

  // Handle notification click action
  /* Future<void> _handleNotificationClick(RemoteMessage message) async {
    log('firebase :: User tapped on notification: ${message.notification?.title}');
    // You can navigate to a specific screen using Navigator here
  }*/

  //Когда приложение открыто
  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (sl<InetCubit>().state) {
      sl<LoadingCubit>().changeValue(true);
      if (payload != null) {
        print('firebase :: Notification payload: $payload');
        sl<NestedWebviewController>().scrollStatus = ScrollStatus.forward;
        sl<NestedWebviewController>().webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(payload)),
        );
        //?.loadRequest(Uri.parse(payload));
      }
    } else {
      sl<NestedWebviewController>().scrollStatus = ScrollStatus.forward;
      sl<NestedWebviewController>().webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(payload!)),
      );
      //?.loadRequest(Uri.parse(payload!));
      sl<ScrollHeightCubit>().updateScrollHeight(0);
      sl<BackgroundCubit>().changeValue(true);
      sl<ErrorTextCubit>().changeValue(false);
      sl<NestedWebviewController>().isFirstRun = true;
      //nestedWebviewController!.isBackgroundNoInternet = true;
    }
  }

  // Background handler (required for background notifications)
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    log('firebase :: Handling a background message: ${message.messageId}');
  }

  // Get device token (you can send this to your server for targeted notifications)
  /* Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("Device Token: $token");
    return token;
  }*/
}
