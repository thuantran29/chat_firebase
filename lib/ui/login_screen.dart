import 'package:chat_firebase/firebase/auth_provider.dart';
import 'package:chat_firebase/ui/register_screen.dart';
import 'package:chat_firebase/utils/conts.dart';
import 'package:chat_firebase/views/stacked_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class LoginPage extends StatefulWidget {
  LoginPage({this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  String _email;
  String _password;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    prefs = await SharedPreferences.getInstance();
    if (validateAndSave()) {
      try {
        var auth = AuthProvider.of(context).auth;
        setState(() {
          isLoading = true;
        });
        String userId =
            await auth.signInWithEmailAndPassword(_email, _password);
        print('Signed in: $userId');
        final QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: userId)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
        setState(() {
          isLoading = false;
        });
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
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
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      RaisedButton(
        key: Key('signIn'),
        child: Text('Login', style: TextStyle(fontSize: 20.0)),
        onPressed: validateAndSubmit,
      ),
      FlatButton(
        child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
        onPressed: moveToRegister,
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
