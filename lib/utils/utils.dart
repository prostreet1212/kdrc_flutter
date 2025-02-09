import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static const String scrollHeightJs = '''(function() {
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
})();''';

  static void showCallDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(),
            title: Text(
              'Приемная',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('Позвонить в приёмную?'),
            actions: [
              TextButton(
                child: Text('Да'),
                onPressed: () async {
                  final Uri _url = Uri.parse('tel:+7-81837-300-50');
                  await launchUrl(
                    _url,
                    mode: LaunchMode.platformDefault,
                  );
                },
              ),
              TextButton(
                child: Text('Нет'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
