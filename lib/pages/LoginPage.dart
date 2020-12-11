import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../pages/SeqPage.dart';

class LoginPage extends StatelessWidget {
  final formkey = GlobalKey<FormState>();
  String username;
  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter username",
                            labelText: "User name",
                          ),
                          controller: myController,
                        ),
                        TextField(
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Enter password",
                            labelText: "Password",
                          ),
                        ),
                        RaisedButton(
                          onPressed: () {
                            username = myController.text;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SeqPage(
                                          name: username,
                                          server: BluetoothDevice(),
                                        )));
                          },
                          color: Colors.black,
                          child: Text(
                            "sign in",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
