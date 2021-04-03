import 'package:flutter/material.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Pages/Dashboard/Tabs/MyForms.dart';
import 'package:gdt/Pages/Dashboard/Tabs/Settings.dart';
import 'package:gdt/Pages/Dashboard/Tabs/CompletedForms.dart';

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
  int _currentIndex = 0;
  List<_DashboardTabItem> _children = [];
  final AlertController alertController = AlertController();

  _DashboardState() {
    _prepareViewData();
  }

  void _prepareViewData() {
    _children.add(_DashboardTabItem(ProjectStrings.myForms, MyForms()));
    _children.add(
        _DashboardTabItem(ProjectStrings.completedForms, CompletedForms()));
    _children.add(_DashboardTabItem(ProjectStrings.settings, Settings()));
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
                        context, ProjectStrings.help, ProjectStrings.helpData);
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
