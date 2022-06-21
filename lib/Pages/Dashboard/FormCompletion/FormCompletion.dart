// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Models/HelpData.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:gdt/Models/CompletedForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Pages/Dashboard/Dashboard.dart';
import 'package:gdt/Pages/Dashboard/Tabs/Settings.dart';

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
  double _formPadding = 16.0;
  Radius _containerCornerRadius = const Radius.circular(16.0);
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CompletedFormModel _completedFormModel;
  QuestionaryModel _questionaryModel;
  QuestionaryModel _filtredQuestionaryModel;
  final AlertController alertController = AlertController();
  Timer _timer;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _chooseAnswersSnackBar = SnackBar(
    content: Text(ProjectStrings.chooseAnswers),
  );
  var _completeChecklistSnackBar = SnackBar(
    content: Text(ProjectStrings.completeChecklist),
  );

  QuestionaryFieldType _lastAddedQuestion;

  int _currentQuestionId = 0;
  bool _isShowLoading = false;

  _FormCompletionState(QuestionaryModel questionaryModel) {
    this._questionaryModel = questionaryModel;
    _prepareViewData();
  }

  void _prepareViewData() {
    this._filtredQuestionaryModel =
        QuestionaryModel.copyFrom(_questionaryModel);
    _filtredQuestionaryModel.questions.removeWhere((element) =>
        (element.keyQuestion ?? "").isNotEmpty &&
        (element.keyQuestionOption ?? "").isNotEmpty);
    _completedFormModel =
        new CompletedFormModel.fromQuestionaryModel(_filtredQuestionaryModel);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: ProjectStrings.projectName,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
            key: _scaffoldKey,
            body: Padding(
                padding: EdgeInsets.all(_formPadding),
                child: new Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: _formPadding),
                      child: Text(_filtredQuestionaryModel.description ?? "",
                          style:
                              TextStyle(fontSize: 12, color: Colors.black87))),
                  _formWidget(),
                  new Stack(children: <Widget>[
                    Visibility(
                      child: Align(
                          alignment: FractionalOffset.bottomLeft,
                          child: MaterialButton(
                              color: Colors.deepPurple,
                              textColor: Colors.white,
                              child: Icon(Icons.arrow_back_rounded),
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
                                        _filtredQuestionaryModel
                                            .questions.length
                                    ? Icons.arrow_forward_rounded
                                    : Icons.done),
                                shape: CircleBorder(),
                                onPressed: () {
                                  _timer.cancel();
                                  if (isFormValid()) {
                                    if (_currentQuestionId + 1 ==
                                        _filtredQuestionaryModel
                                            .questions.length) {
                                      _saveAnswer();
                                      _completeForm();
                                    } else {
                                      setState(() {
                                        _saveAnswer();
                                        ++_currentQuestionId;
                                      });
                                    }
                                  } else if (_filtredQuestionaryModel
                                          .questions[_currentQuestionId].type !=
                                      QuestionaryFieldAbstract.paragraph) {
                                    ScaffoldMessenger.of(
                                            _scaffoldKey.currentContext)
                                        .showSnackBar(_chooseAnswersSnackBar);
                                  }
                                }))
                  ])
                ])),
            appBar: AppBar(
              backgroundColor: Colors.white,
              actions: [
                _questionaryModel.isHasCheckList
                    ? FlatButton(
                        textColor: Colors.deepPurple,
                        onPressed: () async {
                          _showCheckList();
                        },
                        child: Text(ProjectStrings.checklist),
                      )
                    : SizedBox(),
                FlatButton(
                  textColor: Colors.deepPurple,
                  onPressed: () async {
                    alertController.showMessageDialog(
                        context,
                        ProjectStrings.help,
                        ProjectStrings.helpEmail +
                            HelpData.helpEmail +
                            '\n' +
                            ProjectStrings.helpTel +
                            HelpData.helpPhone);
                  },
                  child: Icon(Icons.help_outline_rounded),
                ),
              ],
              leading: BackButton(
                color: Colors.deepPurple,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(_filtredQuestionaryModel.name,
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
            )));
  }

  Widget _formWidget() {
    if (_completedFormModel.questions[_currentQuestionId].isSoFast) {
      var seconds = _filtredQuestionaryModel
              .questions[_currentQuestionId].minQuestionTime ??
          ProjectConstants.defaultQuestionSec;
      _timer = Timer(Duration(seconds: seconds), () {
        print(seconds);
        print("isSoFast = false");
        _completedFormModel.questions[_currentQuestionId].isSoFast = false;
      });
    }
    var matrixHeader =
        _filtredQuestionaryModel.questions[_currentQuestionId].type ==
                QuestionaryFieldAbstract.matrix
            ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                for (var item in (_filtredQuestionaryModel
                        .questions[_currentQuestionId] as MatrixFormField)
                    .optionsControllers)
                  Expanded(
                      child: Text(item.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.black)))
              ])
            : SizedBox();
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
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: _formPadding),
                      child: Text(
                          (_currentQuestionId + 1).toString() +
                              ". " +
                              _filtredQuestionaryModel
                                  .questions[_currentQuestionId]
                                  .questionController
                                  .text,
                          style: TextStyle(fontSize: 14, color: Colors.black))),
                  matrixHeader,
                  Form(
                    key: _formKey,
                    child: _questionsList(),
                  )
                ])));
  }

  Widget _questionsList() {
    switch (_filtredQuestionaryModel.questions[_currentQuestionId].type) {
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
      case QuestionaryFieldAbstract.matrix:
        return _matrixWidget();
        break;
    }
    return Text(ProjectStrings.noQuestions);
  }

  Widget _likertScaleWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
    var completedModel = _completedFormModel.questions[_currentQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(0),
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
                              questionary.optionsControllers[index].text,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black)))));
            }));
  }

  Widget _paragraphWidget() {
    return Expanded(
        child: Container(
            height: double.infinity,
            margin: EdgeInsets.only(bottom: _formPadding),
            child: TextFormField(
              validator: (String value) {
                if (value.isEmpty) {
                  return ProjectStrings.answerCannotBeEmpty;
                }
                return null;
              },
              controller: _filtredQuestionaryModel
                  .questions[_currentQuestionId].optionsControllers.first,
              keyboardType: TextInputType.text,
              maxLines: null,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: ProjectStrings.enterYourAnswer),
            )));
  }

  Widget _multipleChoiseWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
    var completedModel = _completedFormModel.questions[_currentQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(0),
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
                              questionary.optionsControllers[index].text,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black)))));
            }));
  }

  Widget _singleChoiseWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
    var completedModel = _completedFormModel.questions[_currentQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(0),
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
                              questionary.optionsControllers[index].text,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black)))));
            }));
  }

  Widget _sliderWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId]
        as SliderFormField;
    double minValue = 1;
    if (_completedFormModel.questions[_currentQuestionId].selectedOptions !=
            null &&
        _completedFormModel
            .questions[_currentQuestionId].selectedOptions.isNotEmpty) {
    } else {
      _completedFormModel.questions[_currentQuestionId].selectedOptions
          .add(minValue.toString());
    }
    var value = double.parse(_completedFormModel
        .questions[_currentQuestionId].selectedOptions.first);
    return Column(children: [
      Slider(
        value: value,
        min: minValue,
        max: questionary.maxDigit.toDouble(),
        divisions: questionary.maxDigit,
        label: value.round().toString(),
        onChanged: (double value) {
          setState(() {
            _completedFormModel.questions[_currentQuestionId].selectedOptions =
                [value.round().toString()];
          });
        },
      ),
      Row(children: [
        Expanded(
            flex: 2,
            child: Align(
                alignment: FractionalOffset.topLeft,
                child: Text(questionary.minValueController.text,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 10, color: Colors.black)))),
        Expanded(flex: 2, child: SizedBox()),
        Expanded(
            flex: 2,
            child: Align(
                alignment: FractionalOffset.topRight,
                child: Text(questionary.maxValueController.text,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 10, color: Colors.black))))
      ])
    ]);
  }

  Widget _matrixWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId]
        as MatrixFormField;
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.questionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return _matrixFieldWidget(questionary, index);
            }));
  }

  Widget _matrixFieldWidget(MatrixFormField questionary, int index) {
    return new Container(
        margin:
            EdgeInsets.only(bottom: _formPadding / 4, top: _formPadding / 4),
        decoration: new BoxDecoration(
            color: Colors.grey[100],
            borderRadius: new BorderRadius.only(
                topLeft: _containerCornerRadius,
                topRight: _containerCornerRadius,
                bottomLeft: _containerCornerRadius,
                bottomRight: _containerCornerRadius)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (var item in questionary.optionsControllers)
              Expanded(
                  child: Checkbox(
                      value: _completedFormModel.questions
                          .firstWhere((element) =>
                              element.name ==
                              questionary.questionsControllers[index].text)
                          .selectedOptions
                          .contains(item.text),
                      onChanged: (value) {
                        setState(() {
                          _completedFormModel.questions
                              .firstWhere((element) =>
                                  element.name ==
                                  questionary.questionsControllers[index].text)
                              .selectedOptions = [];
                          if (value) {
                            _completedFormModel.questions
                                .firstWhere((element) =>
                                    element.name ==
                                    questionary
                                        .questionsControllers[index].text)
                                .selectedOptions
                                .add(item.text);
                          }
                        });
                      }))
          ]),
          Padding(
              padding: EdgeInsets.all(_formPadding / 2),
              child: Text(questionary.questionsControllers[index].text,
                  style: TextStyle(fontSize: 12, color: Colors.black)))
        ]));
  }

  void _completeForm() {
    if (_completedFormModel.checkList.dateTime == null &&
        _questionaryModel.isHasCheckList) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(_completeChecklistSnackBar);
    } else {
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
                      ProjectConstants.completedFormsCollectionName:
                          FieldValue.arrayUnion(
                              [_completedFormModel.itemsList()])
                    })
                    .then((value) => setState(() {
                          _isShowLoading = false;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()),
                            (Route<dynamic> route) => false,
                          );
                        }))
                    .catchError((error) => {
                          alertController.showMessageDialog(
                              context, ProjectStrings.error, error.message),
                          setState(() {
                            _isShowLoading = false;
                          })
                        })
              });
    }
  }

  void _saveAnswer() {
    switch (_filtredQuestionaryModel.questions[_currentQuestionId].type) {
      case QuestionaryFieldAbstract.paragraph:
        _completedFormModel.questions[_currentQuestionId].selectedOptions.add(
            _filtredQuestionaryModel
                .questions[_currentQuestionId].optionsControllers.first.text);
        break;
      case QuestionaryFieldAbstract.singleChoise:
        _filterQuestionsByKey();
        break;
      default:
        break;
    }
  }

  bool isFormValid() {
    switch (_filtredQuestionaryModel.questions[_currentQuestionId].type) {
      case QuestionaryFieldAbstract.paragraph:
        return _formKey.currentState.validate();
        break;
      case QuestionaryFieldAbstract.matrix:
        bool isMatrixValid = true;
        (_filtredQuestionaryModel.questions[_currentQuestionId]
                as MatrixFormField)
            .questionsControllers
            .forEach((elem) {
          if (_completedFormModel.questions
              .firstWhere((e) => e.name == elem.text)
              .selectedOptions
              .isEmpty) {
            isMatrixValid = false;
          }
        });
        return isMatrixValid;
      default:
        return _completedFormModel
            .questions[_currentQuestionId].selectedOptions.isNotEmpty;
        break;
    }
  }

  void _showCheckList() {
    Widget okButton = FlatButton(
      child: Text(ProjectStrings.ok),
      onPressed: () {
        _completedFormModel.checkList.dateTime = DateTime.now();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_questionaryModel.checkList.nameController.text,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _questionaryModel.checkList.optionsControllers
                        .map((e) => CheckboxListTile(
                              value:
                                  _completedFormModel.checkList.options[e.text],
                              title: Text(e.text),
                              onChanged: (bool value) {
                                setState(() => _completedFormModel
                                    .checkList.options[e.text] = value);
                              },
                            ))
                        .toList());
              },
            ),
            actions: [okButton],
          );
        });
  }

  void _filterQuestionsByKey() {
    var question = _filtredQuestionaryModel.questions[_currentQuestionId]
        as SingleChoiseFormField;
    print(_filtredQuestionaryModel.questions.length);
    var completedQuestion = _completedFormModel.questions[_currentQuestionId];
    if (question.isKeyQuestion) {
      var question = _questionaryModel.questions.firstWhere(
          (element) =>
              completedQuestion.name == element.keyQuestion &&
              completedQuestion.selectedOptions.first ==
                  element.keyQuestionOption,
          orElse: () => null);
      if (question == null &&
          _filtredQuestionaryModel.questions[_currentQuestionId + 1] ==
              _lastAddedQuestion) {
        _lastAddedQuestion = null;
        _filtredQuestionaryModel.questions.removeAt(_currentQuestionId + 1);
        _completedFormModel.questions.removeAt(_currentQuestionId + 1);
      }
      if (question != null &&
          _filtredQuestionaryModel.questions[_currentQuestionId + 1] !=
              question) {
        setState(() {
          _lastAddedQuestion = question;
          _filtredQuestionaryModel.questions
              .insert(_currentQuestionId + 1, question);
          if (question.type == QuestionaryFieldAbstract.matrix) {
            for (var item
                in (question as MatrixFormField).questionsControllers) {
              CompletedFormQuestion completedItem =
                  CompletedFormQuestion.withName(item.text);
              _completedFormModel.questions.add(completedItem);
            }
          } else {
            CompletedFormQuestion completedItem =
                CompletedFormQuestion.fromQuestionaryFieldType(question);
            _completedFormModel.questions
                .insert(_currentQuestionId + 1, completedItem);
          }
        });
      }
    }
  }
}
