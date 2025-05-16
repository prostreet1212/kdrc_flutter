import 'package:flutter/material.dart';
import 'package:kdrc_flutter/widgets/call_dialog.dart';
import 'package:flutter/services.dart';

class Utils {

  // Загрузка изображения из assets
 static Future<Uint8List> loadImageFromAssets(String path) async {
    ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }


  static void showCallDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CallDialog();
        });
  }

  static Route createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Анимация перехода SecondScreen справа налево
        var slideAnimation = Tween<Offset>(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 500),
    );
  }

  static String getTypeFile(String url){
    List<String> parts = url.split('/');
    String fileNameWithExtension = parts.last;
    List<String> fileNameParts = fileNameWithExtension.split('.');
    String fileType = fileNameParts.last;
    return fileType;
  }

  static bool isEmail(String email) {
    // Регулярное выражение для проверки email
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

 static const String scrollHeightJs ='''     (function() {
          var height = 0;
          function checkAndNotify() {
            var curr = document.body.scrollHeight;
            if (curr !== height) {
              height = curr;
              window.flutter_inappwebview.callHandler('onContentHeightChanged', height.toString());
            }
          }
          if (window.ResizeObserver) {
            new ResizeObserver(checkAndNotify).observe(document.body);
          } else {
            setInterval(checkAndNotify, 200);
          }
        })(); ''';

 /* static const String scrollHeightJs = '''(function() {
  var height = 0;
  var notifier = window.ScrollHeightNotifier || window.webkit.messageHandlers.ScrollHeightNotifier;
  if (!notifier) return;

  function checkAndNotify() {
    var curr = document.body.scrollHeight;
    if (curr !== height) {
      height = curr;
      notifier.postMessage(height.toString());
    }
  }

  var timer;
  var ob;
  if (window.ResizeObserver) {
    ob = new ResizeObserver(checkAndNotify);
    ob.observe(document.body);
  } else {
    timer = setTimeout(checkAndNotify, 200);
  }
  window.onbeforeunload = function() {
    ob && ob.disconnect();
    timer && clearTimeout(timer);
  };
})();''';*/
}
