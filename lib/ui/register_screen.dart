import 'package:chat_firebase/firebase/auth_provider.dart';
import 'package:chat_firebase/utils/conts.dart';
import 'package:chat_firebase/views/stacked_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class ConfirmPasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Confirm Password can\'t be empty' : null;
  }
}

class RegisterPage extends StatefulWidget {
  RegisterPage({this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  String _email;
  String _password;
  String _confirm_password;
  bool isLoading;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }


  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  void validateAndSubmit() async {
    prefs = await SharedPreferences.getInstance();
    if (validateAndSave()) {
      try {
        var auth = AuthProvider.of(context).auth;
        setState(() {
          isLoading = true;
        });
        if(_password == _confirm_password){
          String userId =
          await auth.createUserWithEmailAndPassword(_email, _password);

          print('Registered user: $userId');
          Firestore.instance
              .collection('users')
              .document(userId)
              .setData({'nickname': _email, 'photoUrl': "", 'id': userId});
          await prefs.setString('id', userId);
          await prefs.setString('nickname', _email);
          await prefs.setString('photoUrl', "http://file.vforum.vn/hinh/2018/03/hinh-anh-hinh-nen-songoku-dep-nhat-tu-nho-den-lon-3.jpg");
          setState(() {
            isLoading = false;
          });
          moveToLogin();
          widget.onSignedIn();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    }else{
      setState(() {
        isLoading = false;
      });
    }
  }

  void moveToLogin() {
    formKey.currentState.reset();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    StakedIcons(),
                    Container(
                      margin: new EdgeInsets.only(left: 20, right: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: buildInputs() + buildSubmitButtons(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              buildLoading(),
            ],
          ),
        ));
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(labelText: 'Email'),
        validator: EmailFieldValidator.validate,
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        validator: PasswordFieldValidator.validate,
        onSaved: (value) => _password = value,
      ),
      TextFormField(
        key: Key('confirm_password'),
        decoration: InputDecoration(labelText: 'Confirm Password'),
        obscureText: true,
        validator: ConfirmPasswordFieldValidator.validate,
        onSaved: (value) => _confirm_password = value,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      RaisedButton(
        child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
        onPressed: validateAndSubmit,
      ),
      FlatButton(
        child: Text('Have an account? Login', style: TextStyle(fontSize: 20.0)),
        onPressed: moveToLogin,
      ),
    ];
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }
}
