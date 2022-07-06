import 'package:gdt/Models/Questionary.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ResearchProgramModel {
  String id = "";
  String name = "";
  List<ResearchProgramForm> forms = <ResearchProgramForm>[];

  ResearchProgramModel(dynamic object) {
    if (object != null) {
      id = object["id"];
      name = object["name"];
      forms =
          (object["forms"] as List).map((e) => ResearchProgramForm(e)).toList();
    } else {
      id = UniqueKey().toString();
    }
  }

  Map itemsList() {
    return {
      "id": this.id,
      "name": this.name,
      "forms": this.forms.map((e) => e.itemsList()).toList()
    };
  }
}

class ResearchProgramForm {
  String _dateFormat = 'yyyy-MM-dd';
  String formId;
  String formName;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;

  String dateTimeFromString() {
    return dateTimeFrom != null
        ? DateFormat(_dateFormat).format(dateTimeFrom)
        : "";
  }

  String dateTimeToString() {
    return dateTimeTo != null ? DateFormat(_dateFormat).format(dateTimeTo) : "";
  }

  ResearchProgramForm(dynamic object) {
    if (object != null) {
      formId = object["formId"];
      formName = object["formName"];
      if (object["dateTimeFrom"] != null) {
        dateTimeFrom =
            DateTime.fromMillisecondsSinceEpoch(object["dateTimeFrom"] as int);
      }
      if (object["dateTimeTo"] != null) {
        dateTimeTo =
            DateTime.fromMillisecondsSinceEpoch(object["dateTimeTo"] as int);
      }
    }
  }

  ResearchProgramForm.fromQuestionaryModel(QuestionaryModel object) {
    print("ResearchProgramForm from QuestionaryModel");
    formId = object.id;
    formName = object.name;
  }

  Map itemsList() {
    return {
      "formId": this.formId,
      "formName": this.formName,
      "dateTimeFrom": this.dateTimeFrom?.millisecondsSinceEpoch,
      "dateTimeTo": this.dateTimeTo?.millisecondsSinceEpoch
    };
  }
}
