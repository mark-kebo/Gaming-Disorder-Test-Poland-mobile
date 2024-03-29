// @dart=2.9

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gdt/Pages/Login/login.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:intl/intl.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class AppSettings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<AppSettings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  final AlertController alertController = AlertController();
  final _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _formPadding = 24.0;
  double _fieldPadding = 8.0;
  bool _isShowLoading = false;
  String userCollectionId = "";
  String _dateTimeMMss = "yyyy-MM-dd HH:mm:ss";
  bool _isTimerStarted = false;

  _SettingsState() {
    _prepareViewData();
  }

  void _prepareViewData() {
    _isShowLoading = true;
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((user) {
                if (user["id"] == _auth.currentUser.uid) {
                  _nameController.text = user["name"];
                  userCollectionId = user.id;
                  _isTimerStarted = (user["stopTimerDate"] ?? "").isEmpty &&
                      (user["startTimerDate"] ?? "").isNotEmpty;
                }
              })
            })
        .whenComplete(() => setState(() {
              _isShowLoading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return _bodyForm();
  }

  Widget _bodyForm() {
    return Padding(
        padding: EdgeInsets.all(_formPadding),
        child: Container(
            height: double.maxFinite,
            child: new Stack(
              children: <Widget>[
                new Positioned(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(labelText: ProjectStrings.name),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return ProjectStrings.emptyName;
                          }
                          return null;
                        }),
                  ),
                ),
                new Positioned(
                  child: new Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: _formPadding),
                            child: SizedBox(
                              width: double.infinity,
                              child: FlatButton(
                                color: _isTimerStarted
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                onPressed: () async {
                                  _usersCollection
                                      .get()
                                      .then((QuerySnapshot querySnapshot) => {
                                            querySnapshot.docs.forEach((user) {
                                              if (user["id"] ==
                                                  _auth.currentUser.uid) {
                                                bool isTimerStarted =
                                                    (user["stopTimerDate"] ??
                                                                "")
                                                            .isEmpty &&
                                                        (user["startTimerDate"] ??
                                                                "")
                                                            .isNotEmpty;
                                                if (isTimerStarted) {
                                                  _stopTimerAction();
                                                } else {
                                                  _startTimerAction();
                                                }
                                              }
                                            })
                                          });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: _formPadding,
                                      right: _formPadding,
                                      top: _fieldPadding * 2,
                                      bottom: _fieldPadding * 2),
                                  child: Text(
                                      _isTimerStarted
                                          ? ProjectStrings.stopTimer
                                          : ProjectStrings.startTimer,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                ),
                              ),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: _formPadding),
                            child: _isShowLoading
                                ? CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    child: FlatButton(
                                      color: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32.0),
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          _saveAction();
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: _formPadding * 2,
                                            right: _formPadding * 2,
                                            top: _fieldPadding * 2,
                                            bottom: _fieldPadding * 2),
                                        child: Text(ProjectStrings.save,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  )),
                        Padding(
                          padding: EdgeInsets.only(top: _formPadding),
                          child: FlatButton(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            onPressed: () async {
                              _showLogoutAlert();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: _formPadding,
                                  right: _formPadding,
                                  top: _fieldPadding,
                                  bottom: _fieldPadding),
                              child: Text(ProjectStrings.logout,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.deepPurpleAccent)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: _formPadding),
                          child: FlatButton(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            onPressed: () async {
                              _showDeleteAccountAlert();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: _formPadding,
                                  right: _formPadding,
                                  top: _fieldPadding,
                                  bottom: _fieldPadding),
                              child: Text(ProjectStrings.deleteAccount,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.redAccent)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveAction() async {
    setState(() {
      _isShowLoading = true;
    });
    _usersCollection
        .doc(userCollectionId)
        .update({'name': _nameController.text})
        .then((value) => setState(() {
              _isShowLoading = false;
            }))
        .catchError((error) => {
              alertController.showMessageDialog(
                  context, ProjectStrings.error, error),
              setState(() {
                _isShowLoading = false;
              })
            });
  }

  void _startTimerAction() async {
    _usersCollection
        .doc(userCollectionId)
        .update({
          'stopTimerDate': "",
          'startTimerDate': DateFormat(_dateTimeMMss).format(DateTime.now())
        })
        .then((value) => setState(() {
              _isTimerStarted = true;
            }))
        .catchError((error) => {
              alertController.showMessageDialog(
                  context, ProjectStrings.error, error),
            });
  }

  void _stopTimerAction() async {
    _usersCollection
        .doc(userCollectionId)
        .update(
            {'stopTimerDate': DateFormat(_dateTimeMMss).format(DateTime.now())})
        .then((value) => setState(() {
              _isTimerStarted = false;
            }))
        .catchError((error) => {
              alertController.showMessageDialog(
                  context, ProjectStrings.error, error),
            });
  }

  void _showLogoutAlert() {
    alertController.showMessageDialogWithAction(
        context, ProjectStrings.logout, ProjectStrings.logoutQuestion, true,
        () async {
      _logoutAction();
    });
  }

  void _showDeleteAccountAlert() {
    alertController.showMessageDialogWithAction(
        context,
        ProjectStrings.deleteAccount,
        ProjectStrings.deleteAccountQuestion,
        true, () async {
      _deleteAccountAction();
    });
  }

  Future<void> _logoutAction() async {
    _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(ProjectConstants.prefsEmail);
    prefs.remove(ProjectConstants.prefsPassword);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext ctx) => Login()));
  }

  Future<void> _deleteAccountAction() async {
    setState(() {
      _isShowLoading = true;
    });
    _usersCollection
        .doc(userCollectionId)
        .delete()
        .then((value) => setState(() async {
              _auth.currentUser.delete();
              _isShowLoading = false;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove(ProjectConstants.prefsEmail);
              prefs.remove(ProjectConstants.prefsPassword);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext ctx) => Login()));
            }))
        .catchError((error) => {
              alertController.showMessageDialog(
                  context, ProjectStrings.error, error),
              setState(() {
                _isShowLoading = false;
              })
            });
  }
}
