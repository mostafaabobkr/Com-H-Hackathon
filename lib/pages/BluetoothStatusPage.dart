import 'dart:async';
import 'package:agry/pages/SeqPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
// import 'package:scoped_model/scoped_model.dart';

import '../pages/DiscoveryPage.dart';
import '../pages/SelectBondedDevicePage.dart';
import '../pages/Tmp.dart';

class BluetoothStatusPage extends StatefulWidget {
  String name = "";
  // BluetoothDevice server;
  BluetoothStatusPage({Key key, this.name}) : super(key: key);

  @override
  _BluetoothStatusPageState createState() => _BluetoothStatusPageState();
}

class _BluetoothStatusPageState extends State<BluetoothStatusPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connec the Divce"),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            ListTile(title: const Text("General")),
            SwitchListTile(
              title: const Text("Enable Bluetooth"),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                future() async {
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text("Bluetooth State"),
              subtitle: Text(_bluetoothState.toString()),
              trailing: RaisedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Local adapter address'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text("Local adapter name"),
              subtitle: Text(_name),
            ),
            Divider(),
            ListTile(
              title: RaisedButton(
                  child: const Text('Explore'),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DiscoveryPage();
                        },
                      ),
                    );
                  }),
            ),
            ListTile(
              title: RaisedButton(
                child: const Text('Connect'),
                onPressed: () async {
                  final BluetoothDevice selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );

                  _communicate(context, selectedDevice);
                  //? selectedDevice --> Server
                  print(selectedDevice);
                },
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  void _communicate(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SeqPage(
              name: widget.name != null ? widget.name : "ss", server: server);
        },
      ),
    );
  }
}
