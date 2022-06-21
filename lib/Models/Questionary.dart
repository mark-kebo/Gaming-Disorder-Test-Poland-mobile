// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionaryModel {
  String id = "";
  String name = "";
  String description = "";
  String groupId = "";
  String groupName = "";
  bool isHasCheckList = false;

  CheckListQuestionaryField checkList;
  List<QuestionaryFieldType> questions = <QuestionaryFieldType>[];

  QuestionaryModel(String id, DocumentSnapshot snapshot) {
    if (snapshot != null) {
      this.id = id;
      name = snapshot.data()["name"];
      isHasCheckList = snapshot.data()["isHasCheckList"];
      description = snapshot.data()["description"];
      groupId = snapshot.data()["groupId"];
      groupName = snapshot.data()["groupName"];
      checkList = CheckListQuestionaryField(snapshot.data()["checkList"]);
      initQuestions(snapshot);
    }
  }

  QuestionaryModel.copyFrom(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.description = questionary.description;
    this.groupId = questionary.groupId;
    this.groupName = questionary.groupName;
    this.checkList = questionary.checkList;
    this.isHasCheckList = questionary.isHasCheckList;
    this.questions = questionary.questions.map((e) => e).toList();
  }

  void initQuestions(DocumentSnapshot snapshot) {
    for (var form in snapshot.data()['questions']) {
      var field;
      switch (form["key"]) {
        case "likertScale":
          field = LikertScaleFormField(form);
          break;
        case "paragraph":
          field = ParagraphFormField(form);
          break;
        case "multipleChoise":
          field = MultipleChoiseFormField(form);
          break;
        case "singleChoise":
          field = SingleChoiseFormField(form);
          break;
        case "slider":
          field = SliderFormField(form);
          break;
        case "matrix":
          field = MatrixFormField(form);
          break;
      }
      questions.add(field);
    }
  }
}

enum QuestionaryFieldAbstract {
  likertScale,
  paragraph,
  multipleChoise,
  singleChoise,
  slider,
  matrix
}

abstract class QuestionaryFieldType {
  QuestionaryFieldAbstract type;
  String key;
  String name;
  TextEditingController questionController;
  List<TextEditingController> optionsControllers;
  Map itemsList();
  Icon icon;
  String keyQuestion = "";
  String keyQuestionOption = "";
  int minQuestionTime = 0;
}

class LikertScaleFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.likertScale;
  String key = "likertScale";
  TextEditingController questionController = TextEditingController();
  String name = "Likert Scale";
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.linear_scale,
    color: Colors.deepPurple,
  );

  LikertScaleFormField(dynamic item) {
    if (item != null) {
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      questionController.text = item["question"];
      minQuestionTime = item["minTime"];
    }
  }

  Map itemsList() {
    return {
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.text),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime
    };
  }
}

class MatrixFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.matrix;
  String key = "matrix";
  String name = "Matrix";
  List<TextEditingController> questionsControllers = <TextEditingController>[];
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.table_rows_sharp,
    color: Colors.deepPurple,
  );

  MatrixFormField(dynamic item) {
    if (item != null) {
      questionController = TextEditingController(text: "");
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      for (var option in item['questions']) {
        var textController = TextEditingController();
        textController.text = option;
        questionsControllers.add(textController);
      }
      minQuestionTime = item["minTime"];
    }
  }

  Map itemsList() {
    return {
      "key": this.key,
      "questions": this.questionsControllers.map((e) => e.text),
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.text),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime
    };
  }
}

class ParagraphFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.paragraph;
  TextEditingController questionController = TextEditingController();
  String name = "Paragraph";
  String key = "paragraph";
  Icon icon = Icon(
    Icons.format_align_left_outlined,
    color: Colors.deepPurple,
  );
  List<TextEditingController> optionsControllers = <TextEditingController>[];

  ParagraphFormField(dynamic item) {
    if (item != null) {
      optionsControllers.add(TextEditingController());
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTime = item["minTime"];
    }
  }

  Map itemsList() {
    return {
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime
    };
  }
}

class MultipleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.multipleChoise;
  String key = "multipleChoise";
  TextEditingController questionController = TextEditingController();
  String name = "Multiple Choise";
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.check_box_outlined,
    color: Colors.deepPurple,
  );

  MultipleChoiseFormField(dynamic item) {
    if (item != null) {
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTime = item["minTime"];
    }
  }

  Map itemsList() {
    return {
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.text),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime
    };
  }
}

class SingleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.singleChoise;
  String key = "singleChoise";
  TextEditingController questionController = TextEditingController();
  String name = "Single Choise";
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.radio_button_checked_outlined,
    color: Colors.deepPurple,
  );
  bool isKeyQuestion = false;

  SingleChoiseFormField(dynamic item) {
    if (item != null) {
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      isKeyQuestion = item["isKeyQuestion"];
      minQuestionTime = item["minTime"];
    }
  }

  Map itemsList() {
    return {
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "isKeyQuestion": this.isKeyQuestion,
      "options": this.optionsControllers.map((e) => e.text),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime
    };
  }
}

class SliderFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.slider;
  String key = "slider";
  TextEditingController questionController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();
  TextEditingController minValueController = TextEditingController();
  int digitStep = 1;
  int maxDigit = 10;
  String name = "Slider";
  Icon icon = Icon(
    Icons.toggle_on_outlined,
    color: Colors.deepPurple,
  );
  List<TextEditingController> optionsControllers = <TextEditingController>[];

  SliderFormField(dynamic item) {
    if (item != null) {
      optionsControllers.add(TextEditingController());
      maxValueController.text = item["maxValue"];
      minValueController.text = item["minValue"];
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTime = item["minTime"];
      digitStep = item["digitStep"];
      maxDigit = item["maxDigit"];
    }
  }

  Map itemsList() {
    return {
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "maxValue": this.maxValueController.text,
      "minValue": this.minValueController.text,
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime,
      "digitStep": this.digitStep,
      "maxDigit": this.maxDigit
    };
  }
}

class CheckListQuestionaryField {
  TextEditingController nameController = TextEditingController();
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.check_circle_rounded,
    color: Colors.deepPurple,
  );

  CheckListQuestionaryField(dynamic item) {
    if (item != null) {
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      nameController.text = item["name"];
    }
  }

  Map itemsList() {
    return {
      "name": this.nameController.text,
      "options": this.optionsControllers.map((e) => e.text),
    };
  }
}
