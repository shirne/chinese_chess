import 'dart:async';

import 'package:flutter/material.dart';

class CustomerDialog {
  BuildContext context;

  CustomerDialog.of(this.context);

  Future<String> prompt() {}

  Future<bool> confirm(message,
      {String buttonText = 'OK',
      String title = 'Alert',
      String cancelText = 'Cancel'}) {
    Completer complete = Completer<bool>();
    show(
      message is Widget ? '' : message,
      [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              complete.complete(false);
            },
            child: Text(cancelText)),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              complete.complete(true);
            },
            child: Text(buttonText)),
      ],
      title: title,
      body: message is Widget ? message : null,
    );

    return complete.future;
  }

  Future<void> alert(message, [String title = 'Alert', String okText = 'OK']) {
    return show(
      message is Widget ? '' : message,
      [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(okText),
        ),
      ],
      title: title,
      body: message is Widget ? message : null,
    );
  }

  Future<void> show(String message, List<Widget> buttons,
      {Widget body, String title = 'Alert', barrierDismissible = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        List<Widget> conts = message.isEmpty
            ? []
            : message.split('\n').map<Widget>((item) => Text(item)).toList();
        if (body != null) {
          conts.add(body);
        }
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: conts,
            ),
          ),
          actions: buttons,
        );
      },
    );
  }
}
