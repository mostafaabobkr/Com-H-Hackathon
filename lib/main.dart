import 'package:flutter/material.dart';
// import 'pages/BluetoothStatusPage.dart';
import 'pages/LoginPage.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      /*BluetoothStatusPage()*/
      debugShowCheckedModeBanner: false,
    );
  }
}
