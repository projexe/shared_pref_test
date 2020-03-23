import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_stuff.dart';

void main() => runApp(MyApp());

String myImageReference = "";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared preferences',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Shared preference test'),
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
    var _filename = await fetchImageFromPreferences();

    // ios test : have only persisted name therefore add the documents path
    Directory docsDir = await getApplicationDocumentsDirectory();
    myImageReference = '${docsDir.path}/${_filename}';

    setState(() {
      _outputText = _fetchedtext;
      myImageReference = myImageReference ?? "";


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                onImageChanged: (file) async {
                  await persistImageFilename(file);
                    setState(() {}); },
                width: 180,
              ),
              Text(
                '$myImageReference',
              ),
            ],
          ),
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
Future<void> saveImageToPreferences(String _file) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setString('imageFile', _file);
  } catch (e) {
    debugPrint("Failed to save image $_file to Shared preferences : $e");
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
  String _filename;
  try {
    _filename = prefs.getString('imageFile');
  } catch (e) {
    debugPrint('No image file retrieved from shared preferences');
  }
  return _filename;
}

Future<void> persistImageFilename(File file) async {
  // set the pet image to the file path,
  // or if the file is null, set the image to null
  //String _path = file?.path ?? null;

   // ios test : just saving the filename
  String _filename = file?.path?.split("/")?.last ?? null;

  if (_filename == '') _filename = null;
  myImageReference = _filename;
  await saveImageToPreferences(_filename);
}

