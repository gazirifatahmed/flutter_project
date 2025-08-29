import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

void showShippingSweetAlert(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    dismissOnTouchOutside: true,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/delivery.gif',
          height: 200,
        ),
        const SizedBox(height: 16),
        const Text(
          'Product is on the way!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Our delivery partner is speeding towards the customer!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
    btnOkOnPress: () {},
    btnOkColor: Colors.green,
    btnOkText: "Awesome!",
  ).show();
}
