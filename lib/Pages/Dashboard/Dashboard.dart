import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Models/HelpData.dart';
import 'package:gdt/Pages/Dashboard/Tabs/MyForms.dart';
import 'package:gdt/Pages/Dashboard/Tabs/Settings.dart';
import 'package:gdt/Pages/Dashboard/Tabs/CompletedForms.dart';
import 'package:flutter/services.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _DashboardTabItem {
  String name;
  Widget element;

  _DashboardTabItem(String name, Widget element) {
    this.name = name;
    this.element = element;
  }
}

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  CollectionReference _settingsCollection =
      firestore.collection(ProjectConstants.settingsCollectionName);

  int _currentIndex = 0;
  List<_DashboardTabItem> _children = [];
  final AlertController alertController = AlertController();

  _DashboardState() {
    _prepareViewData();
  }

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  void _prepareViewData() {
    _settingsCollection
        .doc(ProjectConstants.settingsContactCollectionName)
        .get()
        .then((value) => {
              HelpData.helpEmail = value["email"],
              HelpData.helpPhone = value["phone"]
            });

    _children.add(_DashboardTabItem(ProjectStrings.myForms, MyForms()));
    _children.add(
        _DashboardTabItem(ProjectStrings.completedForms, CompletedForms()));
    _children.add(_DashboardTabItem(ProjectStrings.settings, AppSettings()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: ProjectStrings.projectName,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: _children[_currentIndex].element,
            appBar: AppBar(
              backgroundColor: Colors.white,
              actions: [
                FlatButton(
                  textColor: Colors.deepPurple,
                  onPressed: () async {
                    alertController.showMessageDialog(
                        context,
                        ProjectStrings.help,
                        ProjectStrings.helpEmail +
                            HelpData.helpEmail +
                            '\n' +
                            ProjectStrings.helpTel +
                            HelpData.helpPhone);
                  },
                  child: Icon(Icons.help_outline_rounded),
                ),
              ],
              title: Text(_children[_currentIndex].name,
                  style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: _onTabTapped,
              currentIndex: _currentIndex,
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.assignment_rounded),
                  label: _children[0].name,
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.assignment_turned_in),
                  label: _children[1].name,
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: _children[2].name)
              ],
            )));
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
