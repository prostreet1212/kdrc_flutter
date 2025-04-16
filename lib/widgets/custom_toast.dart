import 'package:flutter/material.dart';

class CustomToast extends StatelessWidget {
   const CustomToast({Key? key,required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 68.0, left: 40, right: 40),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 0.0, vertical: 4.0),
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(
                  0, 3), // changes position of shadow
            ),
          ],
        ),
        child:  Text(
         message,
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.2,color: Colors.black),
        ),
      ),
    );
  }
}
