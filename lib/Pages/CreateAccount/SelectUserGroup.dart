// @dart=2.9

import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdt/Pages/Dashboard/Dashboard.dart';

// ignore: must_be_immutable
class SelectUserGroup extends StatelessWidget {
  Function random;
  Function(String groupName) groupName;

  SelectUserGroup(Function random, Function(String groupName) groupName) {
    this.random = random;
    this.groupName = groupName;
  }

  @override
  Widget build(BuildContext context) {
    return SelectUserGrouptScreen(random, groupName);
  }
}

// ignore: must_be_immutable
class SelectUserGrouptScreen extends StatelessWidget {
  Function random;
  Function(String groupName) groupName;

  SelectUserGrouptScreen(
      Function random, Function(String groupName) groupName) {
    this.random = random;
    this.groupName = groupName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.deepPurple,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(ProjectStrings.group,
            style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SelectUserGroupList(groupName),
      ),
    );
  }
}

// ignore: must_be_immutable
class SelectUserGroupList extends StatefulWidget {
  Function(String groupName) groupName;

  SelectUserGroupList(Function(String groupName) groupName) {
    this.groupName = groupName;
  }

  @override
  _SelectUserGroupListState createState() =>
      _SelectUserGroupListState(groupName);
}

class _SelectUserGroupListState extends State<SelectUserGroupList> {
  CollectionReference _userGroups =
      firestore.collection(ProjectConstants.groupsCollectionName);
  BorderRadius _borderRadius = BorderRadius.all(Radius.circular(16.0));
  double _fieldPadding = 8.0;
  Function(String groupName) groupName;

  _SelectUserGroupListState(Function(String groupName) groupName) {
    this.groupName = groupName;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _userGroups.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(ProjectStrings.anyError,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return _groupsList(snapshot);
      },
    );
  }

  ListView _groupsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return new ListView(
      children: snapshot.data.docs.map((DocumentSnapshot document) {
        return new GestureDetector(
          child: new Padding(
            padding: EdgeInsets.all(_fieldPadding),
            child: new Container(
              padding: EdgeInsets.all(_fieldPadding),
              decoration: new BoxDecoration(
                  color: Colors.grey[200], borderRadius: _borderRadius),
              child: Text(document.data()['name']),
            ),
          ),
          onTap: () {
            print("group selected");
            Navigator.pop(context);
            groupName(document.data()['name']);
          },
        );
      }).toList(),
    );
  }
}
