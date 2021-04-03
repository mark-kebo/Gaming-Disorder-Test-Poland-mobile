import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Models/CompletedForm.dart';
import 'package:gdt/Helpers/Alert.dart';

// ignore: must_be_immutable
class CompletedFormAnswers extends StatefulWidget {
  CompletedFormModel _formModel;

  CompletedFormAnswers(CompletedFormModel formModel) {
    this._formModel = formModel;
  }

  @override
  State<StatefulWidget> createState() => _CompletedFormAnswersState(_formModel);
}

class _CompletedFormAnswersState extends State<CompletedFormAnswers> {
  double _formPadding = 24.0;
  Radius _containerCornerRadius = const Radius.circular(16.0);
  CompletedFormModel _formModel;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AlertController alertController = AlertController();

  _CompletedFormAnswersState(CompletedFormModel formModel) {
    this._formModel = formModel;
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
                padding: EdgeInsets.all(_formPadding), child: _formWidget()),
            appBar: AppBar(
              backgroundColor: Colors.white,
              actions: [
                FlatButton(
                  textColor: Colors.deepPurple,
                  onPressed: () async {
                    alertController.showMessageDialog(
                        context, ProjectStrings.help, ProjectStrings.helpData);
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
              title: Text(_formModel.name,
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
            child: _questionsList()));
  }

  Widget _questionsList() {
    var questions = _formModel.questions;
    print(questions.first.name);
    return Expanded(
        child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                          title: Text((index + 1).toString() +
                              ". " +
                              questions[index].name),
                          subtitle: Text(
                              questions[index].selectedOptions.join(", ")));
            })
            );
  }
}
