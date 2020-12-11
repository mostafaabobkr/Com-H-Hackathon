import 'dart:typed_data';

import 'package:agry/pages/BluetoothStatusPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum SingingCharacter { sms, whatsapp, phonecall }

class SeqPage extends StatefulWidget {
  String tmp;
  String name;
  final BluetoothDevice server;
  SeqPage({Key key, this.name, this.server}) : super(key: key);

  @override
  _SeqPageState createState() => _SeqPageState();
}

class _SeqPageState extends State<SeqPage> {
  List todos = List();
  String input = "";
  String message = "";
  SingingCharacter _character = SingingCharacter.whatsapp;
  String x;
  String msg = '...';
  String _messageBuffer = '.';
  BluetoothConnection connection;
  Color eval_color = Colors.white;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.server != null) print(widget.name);
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // initState() {
  //   super.initState();
  //   todos.add("item1");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Sequance page",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              accountName: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              title: Text('Sequance page'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeqPage(
                      name: widget.name,
                    ),
                  ),
                );
              },
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black,
            ),
            ListTile(
              title: Text('status page'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BluetoothStatusPage(name: widget.name)));
              },
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (BuildContext contex, int index) {
          return Dismissible(
            key: Key(todos[index]),
            onDismissed: (direction) {
              setState(() {
                todos.removeAt(index);
              });
            },
            child: Card(
              child: ListTileTheme(
                tileColor: eval_color,
                child: ListTile(
                  title: Text(todos[index]),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          eval_color = Colors.white;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Add Sequence"),
                  content: Card(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                                contentPadding: new EdgeInsets.fromLTRB(
                                    20.0, 10.0, 100.0, 10.0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                hintText: 'Enter The Number'),
                            onChanged: (String value) {
                              input = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                                contentPadding: new EdgeInsets.fromLTRB(
                                    20.0, 10.0, 100.0, 10.0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                hintText: 'Enter The Message'),
                            onChanged: (String value) {
                              message = value;
                            },
                          ),
                          Container(
                            child: MyStatefulWidget(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            todos.add("Phone Number : " +
                                input +
                                " \nMessage: " +
                                message);
                          });

                          Navigator.of(context).pop();
                        },
                        child: Text("Add Data"))
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    dataString = (dataString != null) ? dataString : "...";
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        msg = dataString;
        print(msg);
      });
    } else {
      print('bu : ' + _messageBuffer);
      print('msg : ' + dataString);
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    print(msg);
    if (msg != "") {
      eval_color = Colors.blue[300];
      setState(() {});
    }
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  SingingCharacter _character = SingingCharacter.sms;
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('sms'),
          leading: Radio(
            value: SingingCharacter.sms,
            groupValue: _character,
            onChanged: (SingingCharacter value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('phone call'),
          leading: Radio(
            value: SingingCharacter.phonecall,
            groupValue: _character,
            onChanged: (SingingCharacter value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('whatsapp'),
          leading: Radio(
            value: SingingCharacter.whatsapp,
            groupValue: _character,
            onChanged: (SingingCharacter value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
