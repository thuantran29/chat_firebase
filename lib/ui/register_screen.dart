import 'package:chat_firebase/firebase/auth_provider.dart';
import 'package:chat_firebase/views/stacked_icons.dart';
import 'package:flutter/material.dart';

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

  String _email;
  String _password;
  String _confirm_password;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        var auth = AuthProvider.of(context).auth;
        if(_password == _confirm_password){
          String userId =
          await auth.createUserWithEmailAndPassword(_email, _password);
          print('Registered user: $userId');

          widget.onSignedIn();
          moveToLogin();
        }
      } catch (e) {
        print('Error: $e');
      }
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              new SizedBox(height: 20),
              new StakedIcons(),
              new Container(
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
}
