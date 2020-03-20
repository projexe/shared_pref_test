import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_stuff.dart';

void main() => runApp(MyApp());

String myImageReference = "";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _inputText = "";
  String _outputText = "";

  _readFromSharedPref() async {
    var _fetchedtext = await fetchFromPreferences();
    var _image = await fetchImageFromPreferences();
    setState(() {
      _outputText = _fetchedtext;
      myImageReference = _image ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Save to Shared Pref"),
                onSubmitted: (_input) async {
                  await saveToPreferences(_input);
                  setState(() => _inputText = _input);
                }),
            Text(
              'Data persisted to Shared Preferences:',
            ),
            Text(
              '$_inputText',
              style: Theme.of(context).textTheme.display1,
            ),
            OutlineButton(
                onPressed: _readFromSharedPref,
                child: Text("read from Shared Preferences")),
            Text(
              'Data read from Shared Preferences:',
            ),
            Text(
              '$_outputText',
              style: Theme.of(context).textTheme.display1,
            ),
            AFIPhotoFrame(
              myImageReference,
              isEditable: true,
              onImageChanged: (file) =>
                  setState(() => persistImagePath(file)),
              width: 180,
            ),
            Text(
              '$myImageReference',
            ),
          ],
        ),
      ),
    );
  }
}

/// Write ImagePath to shared preferences.
/// If path string is null then clear the shared preference
Future<void> saveToPreferences(String _textToSave) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setString('persistedString', _textToSave);
  } catch (e) {
    debugPrint("Failed to save $_textToSave to Shared preferences : $e");
  }
}
/// Write ImagePath to shared preferences.
/// If path string is null then clear the shared preference
Future<void> saveImageToPreferences(String _path) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setString('imagePath', _path);
  } catch (e) {
    debugPrint("Failed to save image $_path to Shared preferences : $e");
  }
}

/// read ImagePath from shared preferences.
/// Returns the image path or an empty string if there is no stored reference
Future<String> fetchFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String _text;
  try {
    _text = prefs.getString('persistedString');
  } catch (e) {
    debugPrint('No string retrieved from shared preferences');
  }
  return _text;
}
/// read ImagePath from shared preferences.
/// Returns the image path or an empty string if there is no stored reference
Future<String> fetchImageFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String _path;
  try {
    _path = prefs.getString('imagePath');
  } catch (e) {
    debugPrint('No image path retrieved from shared preferences');
  }
  return _path;
}

Future<void> persistImagePath(File file) async {
  // set the pet image to the file path,
  // or if the file is null, set the image to null
  String _path = file?.path ?? null;
  if (_path == '') _path = null;
  myImageReference = _path;
  await saveImageToPreferences(_path);
}

