import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Pages/Login/Login.dart';
import 'package:gdt/Pages/Dashboard/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gdt/Helpers/PushNotificationManager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationsManager().init();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString(ProjectConstants.prefsEmail);
  var password = prefs.getString(ProjectConstants.prefsPassword);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  if (email != null || email != "" || password != null) {
    try {
      User user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      user != null
          ? runApp(MaterialApp(home: Dashboard()))
          : runApp(MaterialApp(home: Login()));
    } catch (error) {
      runApp(MaterialApp(home: Login()));
    }
  } else {
    runApp(MaterialApp(home: Login()));
  }
}