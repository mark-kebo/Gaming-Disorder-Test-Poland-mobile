// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Models/ResearchProgram.dart';
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
  CollectionReference _formsCollection =
      firestore.collection(ProjectConstants.formsCollectionName);
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  CollectionReference _groupsCollection =
      firestore.collection(ProjectConstants.groupsCollectionName);
  CollectionReference _researchProgrammesCollection =
      firestore.collection(ProjectConstants.researchProgrammesCollectionName);
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
                    (doc[ProjectConstants.completedFormsCollectionName] as List)
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
                                  .then((doc) async => {
                                        if ((await _isFormAvailable(
                                                QuestionaryModel(
                                                    form.id, form)) &&
                                            _isUserHasGruop(doc)))
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
    var users = group.data()[ProjectConstants.selectedUsersCollectionName];
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

  Future<bool> _isFormAvailable(QuestionaryModel questionaryModel) async {
    List<ResearchProgramForm> researchProgramForms = [];
    DateTime toDate;
    DateTime fromDate;
    Future<bool> isAvailable = Future.value(true);
    DateTime now = DateTime.now();
    await _researchProgrammesCollection.get().then((programmes) => {
          researchProgramForms = programmes.docs
              .map((e) => ResearchProgramModel(e))
              .map((e) => e.forms)
              .toList()
              .expand((i) => i)
              .toList(),
          if (researchProgramForms
              .map((e) => e.formId)
              .contains(questionaryModel.id))
            {
              fromDate = (researchProgramForms
                      .where((element) => element.formId == questionaryModel.id)
                      .map((e) => e.dateTimeFrom)
                      .toList() as List<DateTime>)
                  .reduce((a, b) => b.isAfter(a) ? a : b),
              toDate = (researchProgramForms
                      .where((element) => element.formId == questionaryModel.id)
                      .map((e) => e.dateTimeTo)
                      .toList() as List<DateTime>)
                  .reduce((a, b) => a.isAfter(b) ? a : b),
              isAvailable =
                  Future.value(fromDate.isBefore(now) && toDate.isAfter(now)),
              print(questionaryModel.name),
              print("--from---> $fromDate"),
              print("---to--> $toDate"),
              print("-"),
            }
        });
    print("return $isAvailable");
    return isAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return _listView();
  }

  Widget _listView() {
    if (_isShowLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_forms.isEmpty) {
      return Center(child: Text(ProjectStrings.dontHaveSurveys));
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
