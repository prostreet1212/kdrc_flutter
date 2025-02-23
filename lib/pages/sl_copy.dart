
import 'package:flutter/material.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview.dart';


class SlWebCopy extends StatefulWidget {
  const SlWebCopy({super.key});

  @override
  State<SlWebCopy> createState() => _SlWebCopyState();
}

class _SlWebCopyState extends State<SlWebCopy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NestedWebviewController nestedWebviewController = NestedWebviewController(
        initialUrl: 'https://kdrc.ru/novosti', context: context);
    bool isCollapsed = false;
    nestedWebviewController.init();
    return WillPopScope(
      onWillPop: () async {
        if (await nestedWebviewController.webViewController!.canGoBack()) {
          nestedWebviewController.scrollStatus = ScrollStatus.prev;
          nestedWebviewController.webViewController!.goBack();
          return false;
        }else{
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            controller: nestedWebviewController.nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                CustomAppBar(),
              ];
            },
            body:
                SliverWebview(nestedWebviewController: nestedWebviewController),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(onPressed: () {
                // myKey.currentState!.innerController.jumpTo(10);
                //myKey.currentState!.innerController.position.setPixels(50);
                //myKey.currentState!.innerController.position.pixels;
              }),
              FloatingActionButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
