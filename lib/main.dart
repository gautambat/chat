import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/users.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isLogin = false;

  _checkLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isLogin = preferences.get('isLogin') ?? false;

    setState(() {
      _isLogin = isLogin;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat App",
      theme: ThemeData(primarySwatch: Colors.red),
      home: _isLogin ? Users() : Home(),
    );
  }
}

