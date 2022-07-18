// @dart=2.9

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => instance;

  static final PushNotificationsManager instance = PushNotificationsManager._();
  SharedPreferences _prefs;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(ProjectConstants.prefsIsOpenFromPush, false);
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          _prefs.setBool(ProjectConstants.prefsIsOpenFromPush, true);
        },
        onBackgroundMessage: Fcm.backgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          _prefs.setBool(ProjectConstants.prefsIsOpenFromPush, true);
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  Future<bool> isAvailable() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }
}

class Fcm {
  static Future<dynamic> backgroundMessageHandler(
      Map<String, dynamic> message) async {
    print("onBackgroundMessage: $message");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(ProjectConstants.prefsIsOpenFromPush, true);
    if (message.containsKey('data')) {
      // Handle data message
      print(message['data']);
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      print(message['notification']);
    }
  }
}
