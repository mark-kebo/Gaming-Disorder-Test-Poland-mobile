import 'package:gdt/Models/Questionary.dart';

class CompletedFormModel {
  String id = "";
  String name = "";
  CompletedCheckList checkList;
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];

  CompletedFormModel(dynamic object) {
    id = object["id"];
    name = object["name"];
    checkList = CompletedCheckList(object["checkList"]);
    questions = (object["questions"] as List)
        .map((e) => CompletedFormQuestion(e))
        .toList();
  }

  CompletedFormModel.fromQuestionaryModel(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.checkList =
        CompletedCheckList.fromQuestionaryModel(questionary.checkList);
    this.questions = questionary.questions
        .map((e) => CompletedFormQuestion.fromQuestionaryFieldType(e))
        .toList();
  }

  Map itemsList() {
    return this.checkList.dateTime == null
        ? {
            "id": this.id,
            "name": this.name,
            "questions": this.questions.map((e) => e.itemsList()).toList()
          }
        : {
            "id": this.id,
            "name": this.name,
            "checkList": this.checkList.itemsList(),
            "questions": this.questions.map((e) => e.itemsList()).toList()
          };
  }
}

class CompletedCheckList {
  String name = "";
  DateTime dateTime;
  Map<String, bool> options = Map<String, bool>();

  CompletedCheckList(dynamic object) {
    if (object != null) {
      name = object["name"];
      dateTime = DateTime.fromMillisecondsSinceEpoch(object["dateTime"] as int);
      (object["options"] as Map<String, dynamic>).forEach((key, value) {
        options[key] = value as bool;
      });
    }
  }

  CompletedCheckList.fromQuestionaryModel(CheckListQuestionaryField object) {
    name = object.nameController.text;
    for (var option in object.optionsControllers) {
      options[option.text] = false;
    }
  }

  Map itemsList() {
    return {
      "name": this.name,
      "dateTime":
          this.dateTime != null ? this.dateTime.millisecondsSinceEpoch : null,
      "options": this.options
    };
  }
}

class CompletedFormQuestion {
  String name = "";
  bool isSoFast = true;
  List<String> selectedOptions = <String>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    isSoFast = object["isSoFast"];
    selectedOptions =
        (object["selectedOptions"] as List).map((e) => e as String).toList();
  }

  CompletedFormQuestion.fromQuestionaryFieldType(QuestionaryFieldType field) {
    name = field.questionController.text;
  }

  Map itemsList() {
    return {
      "name": this.name,
      "isSoFast": this.isSoFast,
      "selectedOptions": this.selectedOptions.map((e) => e).toList()
    };
  }
}
