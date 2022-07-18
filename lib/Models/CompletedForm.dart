// @dart=2.9

import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Models/Questionary.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedFormModel {
  String id = "";
  String name = "";
  String message = "";
  int minPoints = 0;
  CompletedCheckList checkList;
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];
  DateTime startDate;

  CompletedFormModel(dynamic object) {
    id = object["id"];
    name = object["name"];
    minPoints = object["minPoints"];
    message = object["message"];
    checkList = CompletedCheckList(object["checkList"]);
    questions = (object["questions"] as List)
        .map((e) => CompletedFormQuestion(e))
        .toList();
  }

  CompletedFormModel.fromQuestionaryModel(QuestionaryModel questionary) {
    startDate = DateTime.now();
    this.id = questionary.id;
    this.name = questionary.name;
    this.message = questionary.message;
    this.minPoints = int.tryParse(questionary.minPointsToMessage) ?? 0;
    this.checkList =
        CompletedCheckList.fromQuestionaryModel(questionary.checkList);
    this.questions = [];
    questionary.questions.forEach((element) {
      switch (element.type) {
        case QuestionaryFieldAbstract.matrix:
          for (var item in (element as MatrixFormField).questionsControllers) {
            this.questions.add(CompletedFormQuestion.withName(item.text));
          }
          break;
        default:
          this
              .questions
              .add(CompletedFormQuestion.fromQuestionaryFieldType(element));
          break;
      }
    });
  }

  bool isSuspicious() {
    return this.questions.where((element) => element.isSoFast).isNotEmpty ||
        getPoints() < this.minPoints;
  }

  int getPoints() {
    int count = 0;
    questions.forEach((element) async {
      count += element.getSelectedPoints();
    });
    return count;
  }

  Future<Map> itemsList() async {
    Location location = new Location();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime dateLogToApp = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt(ProjectConstants.prefsDateLogToApp) ?? 0);
    Duration timeLogToApp = DateTime.now().difference(dateLogToApp);
    LocationData locationData = await location.getLocation();
    bool isOpenFromPush =
        prefs.getBool(ProjectConstants.prefsIsOpenFromPush ?? false);
    Duration startToAnswerTime = startDate.difference(dateLogToApp);
    return this.checkList.dateTime == null
        ? {
            "id": this.id,
            "name": this.name,
            "message": this.message,
            "minPoints": this.minPoints,
            "isSuspicious": isSuspicious(),
            "dateLogToApp": _printDuration(timeLogToApp),
            "isOpenFromPush": isOpenFromPush,
            "locationData":
                "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude},",
            "startToAnswerTime": _printDuration(startToAnswerTime),
            "questions": this.questions.map((e) => e.itemsList()).toList()
          }
        : {
            "id": this.id,
            "name": this.name,
            "message": this.message,
            "minPoints": this.minPoints,
            "isSuspicious": isSuspicious(),
            "checkList": this.checkList.itemsList(),
            "dateLogToApp": _printDuration(timeLogToApp),
            "isOpenFromPush": isOpenFromPush,
            "locationData":
                "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude},",
            "startToAnswerTime": _printDuration(startToAnswerTime),
            "questions": this.questions.map((e) => e.itemsList()).toList()
          };
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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
  String points = "";
  List<CompletedFormSelectedOptionQuestion> selectedOptions =
      <CompletedFormSelectedOptionQuestion>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    isSoFast = object["isSoFast"];
    points = object["points"].toString();
    selectedOptions = (object["selectedOptions"] as List)
        .map((e) => CompletedFormSelectedOptionQuestion.json(e))
        .toList();
  }

  CompletedFormQuestion.fromQuestionaryFieldType(QuestionaryFieldType field) {
    name = field.questionController.text;
  }

  CompletedFormQuestion.withName(String name) {
    this.name = name;
  }

  int getSelectedPoints() {
    int optionsPointCount = 0;
    selectedOptions.forEach((element) {
      optionsPointCount += element.points;
    });
    return points.isEmpty ? optionsPointCount : int.tryParse(points) ?? 0;
  }

  Map itemsList() {
    return {
      "points": getSelectedPoints(),
      "name": this.name,
      "isSoFast": this.isSoFast,
      "selectedOptions": this.selectedOptions.map((e) => e.itemsList()).toList()
    };
  }
}

class CompletedFormSelectedOptionQuestion {
  String text = "";
  int points = 0;
  DateTime date;
  int timeSec = 0;
  bool isOther = false;

  CompletedFormSelectedOptionQuestion(String text, String points) {
    this.text = text;
    this.points = int.tryParse(points) ?? 0;
  }

  CompletedFormSelectedOptionQuestion.other(
      String text, String points, bool isOther) {
    this.text = text;
    this.points = int.tryParse(points) ?? 0;
    this.isOther = isOther;
  }

  CompletedFormSelectedOptionQuestion.json(dynamic object) {
    text = object["text"];
    date = DateTime.fromMillisecondsSinceEpoch(object["date"] as int);
    timeSec = object["timeSec"];
  }

  void setTime(int timeSec) {
    this.timeSec = timeSec;
    this.date = DateTime.now();
  }

  Map itemsList() {
    return {
      "text": this.text,
      "date": this.date?.millisecondsSinceEpoch ?? 0,
      "timeSec": this.timeSec
    };
  }
}
