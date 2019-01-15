import 'package:chat_firebase/firebase/auth.dart';
import 'package:chat_firebase/firebase/auth_provider.dart';
import 'package:chat_firebase/ui/root_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RootPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
