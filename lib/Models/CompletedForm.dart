import 'package:gdt/Models/Questionary.dart';

class CompletedFormModel {
  String id = "";
  String name = "";
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];

  CompletedFormModel(dynamic object) {
    id = object["id"];
    name = object["name"];
    questions = (object["questions"] as List)
        .map((e) => CompletedFormQuestion(e))
        .toList();
  }

  CompletedFormModel.fromQuestionaryModel(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.questions = questionary.questions
        .map((e) => CompletedFormQuestion.fromQuestionaryFieldType(e))
        .toList();
  }
}

class CompletedFormQuestion {
  String name = "";
  List<String> selectedOptions = <String>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    selectedOptions =
        (object["selectedOptions"] as List).map((e) => e as String).toList();
  }

  CompletedFormQuestion.fromQuestionaryFieldType(QuestionaryFieldType field) {
    name = field.name;
  }
}
