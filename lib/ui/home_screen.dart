import 'package:chat_firebase/firebase/auth_provider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  final String currentUserId;
  final VoidCallback onSignedOut;
  HomePage({Key key, this.currentUserId, this.onSignedOut}) : super(key: key);

  @override
  State createState() => HomePageState(currentUserId: currentUserId);
}

class HomePageState extends State<HomePage>{
  HomePageState({Key key, @required this.currentUserId});

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
//      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  final String currentUserId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(currentUserId),
          actions: <Widget>[
            FlatButton(
                child: Text('Logout',
                    style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () => _signOut(context))
          ],
        ),
        body: Container(
          child: Center(
              child: Text('Welcome', style: TextStyle(fontSize: 32.0))),
        ));
    return null;
  }
}


