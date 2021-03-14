import 'package:flutter/material.dart';

class AlertController {
  void showMessageDialog(
      BuildContext context, String titleText, String bodyText) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(titleText),
      content: Text(bodyText),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showMessageDialogWithAction(BuildContext context, String titleText,
      String bodyText, Function okAction) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        okAction();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(titleText),
      content: Text(bodyText),
      actions: [okButton, cancelButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showDialogWithAction(BuildContext context, String titleText,
      String bodyText, List<FlatButton> actions) {
    AlertDialog alert = AlertDialog(
      title: Text(titleText),
      content: Text(bodyText),
      actions: actions,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}