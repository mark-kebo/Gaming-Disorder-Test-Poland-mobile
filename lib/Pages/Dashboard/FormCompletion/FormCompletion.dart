import 'package:flutter/material.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:gdt/Models/CompletedForm.dart';

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
  CompletedFormModel _completedFormModel;
  QuestionaryModel _questionaryModel;
  int _currentQuestionId = 0;

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
                        onPressed: () {})),
                visible: _currentQuestionId != 0,
              ),
              Align(
                  alignment: FractionalOffset.bottomRight,
                  child: MaterialButton(
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      child: Icon(_currentQuestionId + 1 !=
                              _questionaryModel.questions.length
                          ? Icons.arrow_forward_rounded
                          : Icons.done),
                      padding: EdgeInsets.all(16),
                      shape: CircleBorder(),
                      onPressed: () {}))
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
    return Text("Brak pytań");
  }

  Widget _paragraphWidget() {
    return Expanded(
        child: Container(
            height: double.infinity,
            margin: EdgeInsets.only(bottom: _formPadding * 2),
            child: TextField(
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
    return Text("Brak pytań");
  }

  Widget _singleChoiseWidget() {
    return Text("Brak pytań");
  }

  Widget _sliderWidget() {
    return Text("Brak pytań");
  }
}
