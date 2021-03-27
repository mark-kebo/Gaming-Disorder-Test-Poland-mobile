import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Pages/Dashboard/FormCompletion/FormCompletion.dart';
import 'package:gdt/Models/CompletedForm.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class MyForms extends StatefulWidget {
  @override
  _MyFormsState createState() => _MyFormsState();
}

class _MyFormsState extends State<MyForms> {
  List<QuestionaryModel> _forms = <QuestionaryModel>[];
  List<CompletedFormModel> _completedForms = <CompletedFormModel>[];
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference _formsCollection = firestore.collection('forms');
  CollectionReference _usersCollection = firestore.collection('users');
  CollectionReference _groupsCollection = firestore.collection('user_groups');
  Radius _listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareViewData();
  }

  void _prepareViewData() {
    _isShowLoading = true;
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["id"] == firebaseAuth.currentUser.uid) {
                  setState(() {
                    (doc["completedForms"] as List)
                        .map((e) => CompletedFormModel(e))
                        .toList()
                        .forEach((element) {
                      _completedForms.add(element);
                    });
                  });
                }
              })
            })
        .whenComplete(() => {
              _formsCollection
                  .get()
                  .then((QuerySnapshot querySnapshot) => {
                        querySnapshot.docs.forEach((form) async {
                          var isNotCompleted = _completedForms
                              .where((element) => element.id == form.id)
                              .isEmpty;
                          if (isNotCompleted) {
                            if (form["groupId"] != "") {
                              await _groupsCollection
                                  .doc(form["groupId"])
                                  .get()
                                  .then((doc) => {
                                        if (_isUserHasGruop(doc))
                                          {
                                            _forms.add(
                                                QuestionaryModel(form.id, form))
                                          }
                                      })
                                  .whenComplete(() => setState(() {
                                        _isShowLoading = false;
                                      }));
                            }
                          }
                        })
                      })
                  .whenComplete(() => {
                        Timer(Duration(seconds: 2), () {
                          setState(() {
                            _isShowLoading = false;
                          });
                        })
                      })
            });
  }

  bool _isUserHasGruop(DocumentSnapshot group) {
    var isGroupHasUser = false;
    var users = group.data()["selectedUsers"];
    if (users != null) {
      users.forEach((element) async {
        if (element == firebaseAuth.currentUser.uid) {
          print(firebaseAuth.currentUser.uid);
          isGroupHasUser = true;
        }
      });
    }
    return isGroupHasUser;
  }

  @override
  Widget build(BuildContext context) {
    return _listView();
  }

  Widget _listView() {
    if (_isShowLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_forms.isEmpty) {
      return Center(child: Text("Nie masz w tej chwili dostępnych ankiet"));
    } else {
      return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _forms.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Container(
                        decoration: new BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: new BorderRadius.only(
                                topLeft: _listElementCornerRadius,
                                topRight: _listElementCornerRadius,
                                bottomLeft: _listElementCornerRadius,
                                bottomRight: _listElementCornerRadius)),
                        child: ListTile(
                            title: Text(_forms[index].name),
                            subtitle: Text(_forms[index].description)))),
                onTap: () async {
                  print(_forms[index]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) =>
                              FormCompletion(_forms[index])));
                });
          });
    }
  }
}
