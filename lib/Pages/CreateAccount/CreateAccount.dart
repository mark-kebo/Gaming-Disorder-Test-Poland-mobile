// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdt/Helpers/Alert.dart';
import 'package:gdt/Helpers/Constants.dart';
import 'package:gdt/Helpers/Strings.dart';
import 'package:gdt/Pages/Dashboard/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class CreateAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CreateAccountScreen();
  }
}

class CreateAccountScreen extends StatelessWidget {
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
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: CreateAccountForm(),
      ),
    );
  }
}

class CreateAccountForm extends StatefulWidget {
  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  CollectionReference _users =
      firestore.collection(ProjectConstants.usersCollectionName);

  final AlertController alertController = AlertController();

  double _formPadding = 24.0;
  double _fieldPadding = 8.0;
  bool _isShowLoading = false;

  @override
  Widget build(BuildContext context) {
    return _bodyForm();
  }

  Widget _bodyForm() {
    return SingleChildScrollView(
        child: Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(_formPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: _formPadding),
                child: Text(ProjectStrings.createNewAccount,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4)),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: ProjectStrings.name),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return ProjectStrings.emptyName;
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: ProjectStrings.email),
                  validator: (String value) {
                    bool emailValid =
                        RegExp(ProjectConstants.emailRegExp).hasMatch(value);
                    if (!emailValid || value.isEmpty) {
                      return ProjectStrings.emailNotValid;
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(_fieldPadding),
              child: TextFormField(
                  controller: _passwordController,
                  decoration:
                      InputDecoration(labelText: ProjectStrings.password),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return ProjectStrings.emptyPassword;
                    }
                    if (value.length < 6) {
                      return ProjectStrings.passwordNotValid;
                    }
                    return null;
                  },
                  obscureText: true),
            ),
            Padding(
              padding: EdgeInsets.only(top: _formPadding * 2),
              child: _isShowLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _createAccountAction();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: _formPadding * 2,
                              right: _formPadding * 2,
                              top: _fieldPadding * 2,
                              bottom: _fieldPadding * 2),
                          child: Text(ProjectStrings.create,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      )),
            ),
          ],
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccountAction() async {
    setState(() {
      _isShowLoading = true;
    });
    final FirebaseAuth _auth = FirebaseAuth.instance;
    print("Zaloguj");
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(ProjectConstants.prefsEmail, _emailController.text);
      prefs.setString(ProjectConstants.prefsPassword, _passwordController.text);
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _users.add({
        'name': _nameController.text,
        "id": _auth.currentUser.uid
      }).catchError((error) => alertController.showMessageDialog(
          context, ProjectStrings.error, error.message));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext ctx) => Dashboard()));
      setState(() {
        _isShowLoading = false;
      });
    } catch (error) {
      alertController.showMessageDialog(
          context, ProjectStrings.error, error.message);
      setState(() {
        _isShowLoading = false;
      });
    }
  }
}
