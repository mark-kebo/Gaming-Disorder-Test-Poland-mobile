class CompletedForm {
  String id = "";
  String name = "";
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];

  CompletedForm(dynamic object) {
    id = object["id"];
    name = object["name"];
    questions = (object["questions"] as List).map((e) => CompletedFormQuestion(e)).toList();
  }
}

class CompletedFormQuestion {
  String name = "";
  List<String> selectedOptions = <String>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    selectedOptions = (object["selectedOptions"] as List).map((e) => e as String).toList();
  }
}
