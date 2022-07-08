// @dart=2.9

import 'dart:async';
import 'dart:typed_data';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/RequestServise.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Models/HelpData.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:gdt/Models/CompletedForm.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:gdt/Pages/Dashboard/Dashboard.dart';

import 'FullScreenImagePage.dart';

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
  List<DragAndDropList> _dragAndDropListContents;
  RequestServiseAbstract _requestServise = RequestServise();

  int _currentQuestionId = 0;
  int _currentCompletedQuestionId = 0;
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
    String instructions =
        _filtredQuestionaryModel.questions[_currentQuestionId].instructions ??
            "";
    return MaterialApp(
        title: ProjectStrings.projectName,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            body: Padding(
                padding: EdgeInsets.all(_formPadding),
                child: new Column(children: <Widget>[
                  instructions.isEmpty
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.only(bottom: _formPadding),
                          child: Text(instructions,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87))),
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
                                  if (_filtredQuestionaryModel
                                          .questions[_currentQuestionId].type ==
                                      QuestionaryFieldAbstract.matrix) {
                                    _currentCompletedQuestionId -=
                                        (_filtredQuestionaryModel.questions[
                                                        _currentQuestionId]
                                                    as MatrixFormField)
                                                .questionsControllers
                                                .length -
                                            1;
                                  }
                                  --_currentQuestionId;
                                  --_currentCompletedQuestionId;
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
                                        ++_currentCompletedQuestionId;
                                        if (_filtredQuestionaryModel
                                                .questions[_currentQuestionId]
                                                .type ==
                                            QuestionaryFieldAbstract.matrix) {
                                          _currentCompletedQuestionId +=
                                              (_filtredQuestionaryModel
                                                                  .questions[
                                                              _currentQuestionId]
                                                          as MatrixFormField)
                                                      .questionsControllers
                                                      .length -
                                                  1;
                                        }
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
    if (_completedFormModel.questions[_currentCompletedQuestionId].isSoFast) {
      var seconds = _filtredQuestionaryModel
              .questions[_currentQuestionId].minQuestionTime ??
          ProjectConstants.defaultQuestionSec;
      _timer = Timer(Duration(seconds: seconds), () {
        print(seconds);
        print("isSoFast = false");
        _completedFormModel.questions[_currentCompletedQuestionId].isSoFast =
            false;
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
                  (_filtredQuestionaryModel.questions[_currentQuestionId]
                                  .questionController.text ??
                              "")
                          .isEmpty
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.only(bottom: _formPadding),
                          child: Text(
                              (_currentQuestionId + 1).toString() +
                                  ". " +
                                  _filtredQuestionaryModel
                                      .questions[_currentQuestionId]
                                      .questionController
                                      .text,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black))),
                  (_filtredQuestionaryModel
                                  .questions[_currentQuestionId].image ??
                              Uint8List(0))
                          .isEmpty
                      ? SizedBox()
                      : _questionImage(
                          _filtredQuestionaryModel
                              .questions[_currentQuestionId],
                          _currentQuestionId),
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
      case QuestionaryFieldAbstract.dragAndDrop:
        return _dragAndDropWidget();
        break;
    }
    return Text(ProjectStrings.noQuestions);
  }

  Widget _likertScaleWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
    var completedModel =
        _completedFormModel.questions[_currentCompletedQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(0),
                  child: new Container(
                      child: CheckboxListTile(
                          value: completedModel.selectedOptions
                              .map((e) => e.text)
                              .contains(
                                  questionary.optionsControllers[index].text),
                          onChanged: (value) {
                            setState(() {
                              completedModel.selectedOptions = [];
                              if (value) {
                                completedModel.selectedOptions.add(
                                    CompletedFormSelectedOptionQuestion(
                                        questionary
                                            .optionsControllers[index].text));
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
                ParagraphFormField formField = (_filtredQuestionaryModel
                    .questions[_currentQuestionId] as ParagraphFormField);
                String regEx = formField.regEx ?? "";
                bool valueValid = RegExp(r'' + regEx).hasMatch(value) ?? false;
                if ((value ?? "").isEmpty) {
                  return ProjectStrings.answerCannotBeEmpty;
                } else if (!valueValid) {
                  return formField.validationError();
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

  void _prepareDragAndDropWidget() {
    if ((_filtredQuestionaryModel.questions[_currentQuestionId].type) ==
        QuestionaryFieldAbstract.dragAndDrop) {
      var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
      List<DragAndDropItem> dragAndDropOptions = questionary.optionsControllers
          .map((e) => DragAndDropItem(
              child: Container(
                  margin: EdgeInsets.only(
                      bottom: _formPadding / 4, top: _formPadding / 4),
                  decoration: new BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: new BorderRadius.only(
                          topLeft: _containerCornerRadius,
                          topRight: _containerCornerRadius,
                          bottomLeft: _containerCornerRadius,
                          bottomRight: _containerCornerRadius)),
                  child: ListTile(
                      trailing: Icon(Icons.drag_handle_outlined),
                      title: Text(
                        e.text,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      )))))
          .toList();
      _dragAndDropListContents = List.generate(1, (index) {
        return DragAndDropList(
          children: dragAndDropOptions,
        );
      });
      _changeDragAndDropOption(questionary);
    }
  }

  Widget _dragAndDropWidget() {
    if ((_dragAndDropListContents ?? []).isEmpty) {
      _prepareDragAndDropWidget();
    }
    return Expanded(
        child: DragAndDropLists(
            children: _dragAndDropListContents, onItemReorder: _onItemReorder));
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
    setState(() {
      var movedQuestionaryItem =
          questionary.optionsControllers.removeAt(oldItemIndex);
      questionary.optionsControllers.insert(newItemIndex, movedQuestionaryItem);
      var movedItem = _dragAndDropListContents[oldListIndex]
          .children
          .removeAt(oldItemIndex);
      _dragAndDropListContents[newListIndex]
          .children
          .insert(newItemIndex, movedItem);
    });
    _changeDragAndDropOption(questionary);
  }

  void _changeDragAndDropOption(QuestionaryFieldType questionary) {
    var completedModel =
        _completedFormModel.questions[_currentCompletedQuestionId];
    String selectedOption = "";
    for (var i = 0; i < questionary.optionsControllers.length; i++) {
      int index = i + 1;
      String devider =
          (index == questionary.optionsControllers.length) ? "" : ",    ";
      selectedOption +=
          "[$index]: " + questionary.optionsControllers[i].text + devider;
    }
    completedModel.selectedOptions = [
      CompletedFormSelectedOptionQuestion(selectedOption)
    ];
  }

  Widget _multipleChoiseWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId]
        as MultipleChoiseFormField;
    var completedModel =
        _completedFormModel.questions[_currentCompletedQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              bool isOtherOption =
                  questionary.optionsControllers.length - 1 == index &&
                      questionary.isHasOtherOption;
              return Padding(
                  padding: const EdgeInsets.all(0),
                  child: new Container(
                      child: CheckboxListTile(
                          value: isOtherOption
                              ? questionary.isOtherOptionSelected
                              : completedModel.selectedOptions
                                  .map((e) => e.text)
                                  .contains(questionary
                                      .optionsControllers[index].text),
                          onChanged: (value) {
                            setState(() {
                              if (isOtherOption) {
                                if (questionary.isOtherOptionSelected) {
                                  completedModel.selectedOptions.remove(
                                      completedModel.selectedOptions.firstWhere(
                                          (element) => element.isOther));
                                } else {
                                  completedModel.selectedOptions.add(
                                      CompletedFormSelectedOptionQuestion.other(
                                          questionary
                                              .optionsControllers[index].text,
                                          true));
                                }
                                questionary.isOtherOptionSelected =
                                    !questionary.isOtherOptionSelected;
                              } else if (completedModel.selectedOptions
                                  .map((e) => e.text)
                                  .contains(questionary
                                      .optionsControllers[index].text)) {
                                completedModel.selectedOptions.removeWhere(
                                    (element) =>
                                        questionary
                                            .optionsControllers[index].text ==
                                        element.text);
                              } else {
                                completedModel.selectedOptions.add(
                                    CompletedFormSelectedOptionQuestion(
                                        questionary
                                            .optionsControllers[index].text));
                              }
                            });
                          },
                          title: isOtherOption
                              ? TextFormField(
                                  controller:
                                      questionary.optionsControllers.last,
                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {
                                    setState(() {
                                      completedModel.selectedOptions
                                          .firstWhere(
                                              (element) => element.isOther)
                                          .text = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      hintText: ProjectStrings.otherOption))
                              : Text(questionary.optionsControllers[index].text,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black)))));
            }));
  }

  Widget _singleChoiseWidget() {
    var questionary = _filtredQuestionaryModel.questions[_currentQuestionId];
    var completedModel =
        _completedFormModel.questions[_currentCompletedQuestionId];
    return Expanded(
        child: ListView.builder(
            itemCount: questionary.optionsControllers.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(0),
                  child: new Container(
                      child: CheckboxListTile(
                          value: completedModel.selectedOptions
                              .map((e) => e.text)
                              .contains(
                                  questionary.optionsControllers[index].text),
                          onChanged: (value) {
                            setState(() {
                              completedModel.selectedOptions = [];
                              if (value) {
                                completedModel.selectedOptions.add(
                                    CompletedFormSelectedOptionQuestion(
                                        questionary
                                            .optionsControllers[index].text));
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
    if (_completedFormModel
                .questions[_currentCompletedQuestionId].selectedOptions !=
            null &&
        _completedFormModel.questions[_currentCompletedQuestionId]
            .selectedOptions.isNotEmpty) {
    } else {
      _completedFormModel.questions[_currentCompletedQuestionId].selectedOptions
          .add(CompletedFormSelectedOptionQuestion(minValue.toString()));
    }
    var value = double.parse(_completedFormModel
        .questions[_currentCompletedQuestionId].selectedOptions.first.text);
    return Column(children: [
      Slider(
        value: value,
        min: minValue,
        max: questionary.maxDigit.toDouble(),
        divisions: questionary.maxDigit,
        label: value.round().toString(),
        onChanged: (double value) {
          setState(() {
            _completedFormModel
                .questions[_currentCompletedQuestionId].selectedOptions = [
              CompletedFormSelectedOptionQuestion(value.round().toString())
            ];
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
                          .map((e) => e.text)
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
                                .add(CompletedFormSelectedOptionQuestion(
                                    item.text));
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
      _requestServise.completeForm(
          _completedFormModel.itemsList(),
          (value, errorType) => {
                setState(() {
                  _isShowLoading = false;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                    (Route<dynamic> route) => false,
                  );
                })
              });
    }
  }

  void _saveAnswer() {
    switch (_filtredQuestionaryModel.questions[_currentQuestionId].type) {
      case QuestionaryFieldAbstract.paragraph:
        _completedFormModel
            .questions[_currentCompletedQuestionId].selectedOptions
            .add(CompletedFormSelectedOptionQuestion(_filtredQuestionaryModel
                .questions[_currentQuestionId].optionsControllers.first.text));
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
            .questions[_currentCompletedQuestionId].selectedOptions.isNotEmpty;
        break;
    }
  }

  Widget _questionImage(QuestionaryFieldType fieldType, int index) {
    double imageSize = fieldType.questionController.text.isEmpty &&
            fieldType.type != QuestionaryFieldAbstract.matrix
        ? 180
        : 100;
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        height: imageSize,
        width: imageSize,
        child: fieldType.image.isEmpty
            ? SizedBox()
            : Image.memory(fieldType.image),
      ),
      SizedBox(height: _formPadding / 2, width: _formPadding / 2),
      Container(
          height: imageSize,
          child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(Icons.photo_size_select_large,
                      color: Colors.deepPurple),
                  onPressed: () {
                    print("show image");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        barrierColor: Colors.white,
                        pageBuilder: (BuildContext context, _, __) {
                          return FullScreenImagePage(
                            child: Image.memory(fieldType.image),
                            dark: true,
                          );
                        },
                      ),
                    );
                  })))
    ]);
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
    var completedQuestion =
        _completedFormModel.questions[_currentCompletedQuestionId];
    if (question.isKeyQuestion) {
      var question = _questionaryModel.questions.firstWhere(
          (element) =>
              completedQuestion.name == element.keyQuestion &&
              completedQuestion.selectedOptions.first.text ==
                  element.keyQuestionOption,
          orElse: () => null);
      if (question == null &&
          _filtredQuestionaryModel.questions[_currentQuestionId + 1] ==
              _lastAddedQuestion) {
        _lastAddedQuestion = null;
        _filtredQuestionaryModel.questions.removeAt(_currentQuestionId + 1);
        _completedFormModel.questions.removeAt(_currentCompletedQuestionId + 1);
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
                .insert(_currentCompletedQuestionId + 1, completedItem);
          }
        });
      }
    }
  }
}
