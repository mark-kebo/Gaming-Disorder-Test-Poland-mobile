import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:gdt/Models/CompletedForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Pages/Dashboard/Dashboard.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class FormCompletion extends StatefulWidget {
  QuestionaryModel _questionaryModel;

  FormCompletion(QuestionaryModel questionaryModel) {
    this._questionaryModel = questionaryModel;
  }

  @override
  State<StatefulWidget> createState() =>
      _FormCompletionState(_questionaryModel);
}

class _FormCompletionState extends State<FormCompletion> {
  double _formPadding = 24.0;
  Radius _containerCornerRadius = const Radius.circular(16.0);
  CollectionReference _usersCollection = firestore.collection('users');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CompletedFormModel _completedFormModel;
  QuestionaryModel _questionaryModel;
  final AlertController alertController = AlertController();
  Timer _timer;

  int _currentQuestionId = 0;
  bool _isShowLoading = false;

  _FormCompletionState(QuestionaryModel questionaryModel) {
    this._questionaryModel = questionaryModel;
    _prepareViewData();
  }

  void _prepareViewData() {
    _completedFormModel =
        new CompletedFormModel.fromQuestionaryModel(_questionaryModel);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gaming Disorder Test Poland',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
            body: Padding(
                padding: EdgeInsets.all(_formPadding),
                child: new Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: _formPadding),
                      child: Text(_questionaryModel.description ?? "",
                          style:
                              TextStyle(fontSize: 16, color: Colors.black87))),
                  _formWidget()
                ])),
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: BackButton(
                color: Colors.deepPurple,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(_questionaryModel.name,
                  style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
            )));
  }

  Widget _formWidget() {
    if (_completedFormModel.questions[_currentQuestionId].isSoFast) {
      var seconds =
          _questionaryModel.questions[_currentQuestionId].minQuestionTime;
      _timer = Timer(Duration(seconds: seconds), () {
        print(seconds);
        print("isSoFast = false");
        _completedFormModel.questions[_currentQuestionId].isSoFast = false;
      });
    }
    return Expanded(
        child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            padding: EdgeInsets.all(_formPadding),
            decoration: new BoxDecoration(
                color: Colors.grey[200],
                borderRadius: new BorderRadius.only(
                    topLeft: _containerCornerRadius,
                    topRight: _containerCornerRadius,
                    bottomLeft: _containerCornerRadius,
                    bottomRight: _containerCornerRadius)),
            child: new Stack(children: <Widget>[
              new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(bottom: _formPadding),
                        child: Text(
                            (_currentQuestionId + 1).toString() +
                                ". " +
                                _questionaryModel.questions[_currentQuestionId]
                                    .questionController.text,
                            style:
                                TextStyle(fontSize: 18, color: Colors.black))),
                    Form(
                      key: _formKey,
                      child: _questionsList(),
                    )
                  ]),
              Visibility(
                child: Align(
                    alignment: FractionalOffset.bottomLeft,
                    child: MaterialButton(
                        color: Colors.deepPurple,
                        textColor: Colors.white,
                        child: Icon(Icons.arrow_back_rounded),
                        padding: EdgeInsets.all(16),
                        shape: CircleBorder(),
                        onPressed: () {
                          setState(() {
                            --_currentQuestionId;
                          });
                        })),
                visible: _currentQuestionId != 0,
              ),
              Align(
                  alignment: FractionalOffset.bottomRight,
                  child: _isShowLoading
                      ? CircularProgressIndicator()
                      : MaterialButton(
                          color: Colors.deepPurple,
                          textColor: Colors.white,
                          child: Icon(_currentQuestionId + 1 !=
                                  _questionaryModel.questions.length
                              ? Icons.arrow_forward_rounded
                              : Icons.done),
                          padding: EdgeInsets.all(16),
                          shape: CircleBorder(),
                          onPressed: () {
                            _timer.cancel();
                            if (_currentQuestionId + 1 ==
                                _questionaryModel.questions.length) {
                              if (_formKey.currentState.validate()) {
                                _saveAnswer();
                                _completeForm();
                              }
                            } else {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _saveAnswer();
                                  ++_currentQuestionId;
                                });
                              }
                            }
                          }))
            ])));
  }

  Widget _questionsList() {
    switch (_questionaryModel.questions[_currentQuestionId].type) {
      case QuestionaryFieldAbstract.likertScale:
        return _likertScaleWidget();
        break;
      case QuestionaryFieldAbstract.paragraph:
        return _paragraphWidget();
        break;
      case QuestionaryFieldAbstract.multipleChoise:
        return _multipleChoiseWidget();
        break;
      case QuestionaryFieldAbstract.singleChoise:
        return _singleChoiseWidget();
        break;
      case QuestionaryFieldAbstract.slider:
        return _sliderWidget();
        break;
    }
    return Text("Brak pytań");
  }

  Widget _likertScaleWidget() {
    var questionary = _questionaryModel.questions[_currentQuestionId];
    var completedModel = _completedFormModel.questions[_currentQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Container(
                      child: CheckboxListTile(
                          value: completedModel.selectedOptions.contains(
                              questionary.optionsControllers[index].text),
                          onChanged: (value) {
                            setState(() {
                              completedModel.selectedOptions = [];
                              if (value) {
                                completedModel.selectedOptions.add(
                                    questionary.optionsControllers[index].text);
                              }
                            });
                          },
                          title: Text(
                              questionary.optionsControllers[index].text))));
            }));
  }

  Widget _paragraphWidget() {
    return Expanded(
        child: Container(
            height: double.infinity,
            margin: EdgeInsets.only(bottom: _formPadding * 2),
            child: TextFormField(
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Odpowiedź nie może być pusta';
                }
                return null;
              },
              controller: _questionaryModel
                  .questions[_currentQuestionId].optionsControllers.first,
              keyboardType: TextInputType.text,
              maxLines: null,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Wpisz swoją odpowiedź'),
            )));
  }

  Widget _multipleChoiseWidget() {
    var questionary = _questionaryModel.questions[_currentQuestionId];
    var completedModel = _completedFormModel.questions[_currentQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Container(
                      child: CheckboxListTile(
                          value: completedModel.selectedOptions.contains(
                              questionary.optionsControllers[index].text),
                          onChanged: (value) {
                            setState(() {
                              if (completedModel.selectedOptions.contains(
                                  questionary.optionsControllers[index].text)) {
                                completedModel.selectedOptions.remove(
                                    questionary.optionsControllers[index].text);
                              } else {
                                completedModel.selectedOptions.add(
                                    questionary.optionsControllers[index].text);
                              }
                            });
                          },
                          title: Text(
                              questionary.optionsControllers[index].text))));
            }));
  }

  Widget _singleChoiseWidget() {
    var questionary = _questionaryModel.questions[_currentQuestionId];
    var completedModel = _completedFormModel.questions[_currentQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Container(
                      child: CheckboxListTile(
                          value: completedModel.selectedOptions.contains(
                              questionary.optionsControllers[index].text),
                          onChanged: (value) {
                            setState(() {
                              completedModel.selectedOptions = [];
                              if (value) {
                                completedModel.selectedOptions.add(
                                    questionary.optionsControllers[index].text);
                              }
                            });
                          },
                          title: Text(
                              questionary.optionsControllers[index].text))));
            }));
  }

  Widget _sliderWidget() {
    double maxValue = 10;
    double minValue = 0;
    double value = 0;
    var questionary =
        _questionaryModel.questions[_currentQuestionId] as SliderFormField;
    if (_completedFormModel.questions[_currentQuestionId].selectedOptions !=
            null &&
        _completedFormModel
            .questions[_currentQuestionId].selectedOptions.isNotEmpty) {
      value = double.parse(_completedFormModel
          .questions[_currentQuestionId].selectedOptions.first);
    }
    return Column(children: [
      Slider(
        value: value,
        min: minValue,
        max: maxValue,
        divisions: maxValue.toInt(),
        label: value.round().toString(),
        onChanged: (double value) {
          setState(() {
            _completedFormModel.questions[_currentQuestionId].selectedOptions =
                [value.toString()];
          });
        },
      ),
      Row(children: [
        Expanded(
            flex: 5,
            child: Align(
                alignment: FractionalOffset.centerLeft,
                child: Text(questionary.minValueController.text))),
        Expanded(
            flex: 5,
            child: Align(
                alignment: FractionalOffset.centerRight,
                child: Text(questionary.maxValueController.text)))
      ])
    ]);
  }

  void _completeForm() {
    setState(() {
      _isShowLoading = true;
    });
    String currentUserId;
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                var id = doc["id"];
                if (id == _firebaseAuth.currentUser.uid) {
                  currentUserId = doc.id;
                }
              })
            })
        .whenComplete(() => {
              _usersCollection
                  .doc(currentUserId)
                  .update({
                    'completedForms':
                        FieldValue.arrayUnion([_completedFormModel.itemsList()])
                  })
                  .then((value) => setState(() {
                        _isShowLoading = false;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Dashboard()),
                          (Route<dynamic> route) => false,
                        );
                      }))
                  .catchError((error) => {
                        alertController.showMessageDialog(
                            context, "Błąd", error.message),
                        setState(() {
                          _isShowLoading = false;
                        })
                      })
            });
  }

  void _saveAnswer() {
    switch (_questionaryModel.questions[_currentQuestionId].type) {
      case QuestionaryFieldAbstract.likertScale:
        // return _likertScaleWidget();
        break;
      case QuestionaryFieldAbstract.paragraph:
        _completedFormModel.questions[_currentQuestionId].selectedOptions.add(
            _questionaryModel
                .questions[_currentQuestionId].optionsControllers.first.text);
        break;
      case QuestionaryFieldAbstract.multipleChoise:
        // return _multipleChoiseWidget();
        break;
      case QuestionaryFieldAbstract.singleChoise:
        // return _singleChoiseWidget();
        break;
      case QuestionaryFieldAbstract.slider:
        // return _sliderWidget();
        break;
    }
  }
}
