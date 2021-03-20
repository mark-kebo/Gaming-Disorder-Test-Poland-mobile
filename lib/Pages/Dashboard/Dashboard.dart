import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gdt/Pages/Login/login.dart';
import 'package:gdt/Helpers/Alert.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  CollectionReference _formsCollection = firestore.collection('forms');
  List<Questionary> forms = [];
  final AlertController alertController = AlertController();

  _DashboardState() {
    _prepareViewData();
  }

  void _prepareViewData() {
    _formsCollection.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            forms.add(Questionary(doc));
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gaming Disorder Test Poland',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Dostępne ankiety',
                  style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
              actions: <Widget>[
                IconButton(
                  color: Colors.deepPurple,
                  onPressed: () async {
                    _showLogoutAlert();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ]),
          body: Text("Dash"),
        ));
  }

  void _showLogoutAlert() {
    alertController.showMessageDialogWithAction(
        context, "Wyloguj się", "Czy na pewno chcesz się wylogować?", () async {
      _logoutAction();
    });
  }

  Future<void> _logoutAction() async {
    _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext ctx) => Login()));
  }
}
