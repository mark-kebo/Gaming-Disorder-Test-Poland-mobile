import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Models/CompletedForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Pages/Dashboard/CompletedFormAnswers/CompletedFormAnswers.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class CompletedForms extends StatefulWidget {
  @override
  _CompletedFormsState createState() => _CompletedFormsState();
}

class _CompletedFormsState extends State<CompletedForms> {
  List<CompletedFormModel> _forms = <CompletedFormModel>[];
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  Radius _listElementCornerRadius = const Radius.circular(16.0);
  bool _isShowLoading = false;

  _CompletedFormsState() {
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
                      _forms.add(element);
                    });
                  });
                }
              })
            })
        .whenComplete(() => {
              setState(() {
                _isShowLoading = false;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return _listView();
  }

  Widget _listView() {
    if (_isShowLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_forms.isEmpty) {
      return Center(child: Text(ProjectStrings.dontHaveCompletedSurveys));
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
                        child: ListTile(title: Text(_forms[index].name)))),
                onTap: () async {
                  print(_forms[index]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) =>
                              CompletedFormAnswers(_forms[index])));
                });
          });
    }
  }
}
