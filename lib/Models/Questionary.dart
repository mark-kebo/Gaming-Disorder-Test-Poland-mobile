// @dart=2.9

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Strings.dart';

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
        case "dragAndDrop":
          field = DragAndDropFormField(form);
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
  matrix,
  dragAndDrop
}

abstract class QuestionaryFieldType {
  QuestionaryFieldAbstract type;
  String key;
  String name;
  String instructions;
  TextEditingController questionController;
  List<TextEditingController> optionsControllers;
  Map itemsList();
  Icon icon;
  String keyQuestion = "";
  String keyQuestionOption = "";
  int minQuestionTime = 0;
  Uint8List image;
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
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
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

class DragAndDropFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.dragAndDrop;
  String key = "dragAndDrop";
  TextEditingController questionController = TextEditingController();
  String name = "Ranking";
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.drag_handle_rounded,
    color: Colors.deepPurple,
  );

  DragAndDropFormField(dynamic item) {
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
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
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
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
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

enum ParagraphFormFieldValidationType { text, value }

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
  String regEx;
  String validationType;
  String validationSymbols;

  ParagraphFormField(dynamic item) {
    if (item != null) {
      optionsControllers = [];
      optionsControllers.add(TextEditingController());
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTime = item["minTime"];
      regEx = item["regEx"];
      validationSymbols = item["validationSymbols"];
      validationType = item["validationType"];
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": this.minQuestionTime,
      "regEx": this.regEx,
      "validationType": this.validationType,
      "validationSymbols": this.validationSymbols
    };
  }

  String validationError() {
    ParagraphFormFieldValidationType questionValidationType = validationType ==
            ParagraphFormFieldValidationType.text.toString().split('.').last
        ? ParagraphFormFieldValidationType.text
        : ParagraphFormFieldValidationType.value;
    if ((validationSymbols ?? "").isEmpty) {
      switch (questionValidationType) {
        case ParagraphFormFieldValidationType.text:
          return ProjectStrings.charValues;
          break;
        case ParagraphFormFieldValidationType.value:
          return ProjectStrings.numericValues;
          break;
      }
      return ProjectStrings.answerCannotBeEmpty;
    } else {
      return ProjectStrings.validationSymbols + this.validationSymbols;
    }
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
  bool isHasOtherOption = false;
  bool isOtherOptionSelected = false;

  MultipleChoiseFormField(dynamic item) {
    if (item != null) {
      isHasOtherOption = item["isHasOtherOption"];
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      if (isHasOtherOption) {
        optionsControllers.add(TextEditingController());
      }
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTime = item["minTime"];
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "isHasOtherOption": isHasOtherOption,
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
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
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
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
      instructions = item["instructions"];
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructions,
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
