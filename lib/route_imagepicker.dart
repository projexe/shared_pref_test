import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

///-----------------------------------------------------------------------
///
/// Copyright (c) 2020 Animal Friends Insurance Limited. All rights reserved.
/// Author : Simon Hutton
///
///-----------------------------------------------------------------------

///-----------------------------------------------------------------------
/// Returns image picker screens. Allows user selection of a gallery image or
/// a photo.
/// Selection of the image pops the route off the stack, returning the selected
/// image to the calling process
///-----------------------------------------------------------------------

class RouteImagePicker extends StatefulWidget {
  final File imageFile;
  RouteImagePicker({this.imageFile});

  @override
  _RouteImagePickerState createState() => _RouteImagePickerState(imageFile);
}

class _RouteImagePickerState extends State<RouteImagePicker> {
  File _image;

  _RouteImagePickerState(File imageFile) {
    _image = imageFile;
  }

  // Uses image_picker library and to return a photograph image file
  Future getPhoto() async {
    File photoImageFile;
    try {
      photoImageFile = await ImagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 20);
          // todo : DO WE WANT TO REDUCE HEIGHT AND WIDTH? IF SO UNCOMMENT BELOW
          //maxHeight: 300,
          //maxWidth: 300);
    } catch (e) {
      debugPrint('get photo exception : $e');
    }

    photoImageFile = await cropImage(photoImageFile);

    setState(() {
      _image = photoImageFile;
    });
    // save photo image file to the public gallery (
    GallerySaver.saveImage(photoImageFile.path, albumName: 'AnimalFriends');
  }

  // Uses image_picker library and to return a gallery image file
  Future getGallery() async {
    File galleryImageFile;
    try {
      galleryImageFile = await ImagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 20,
          //maxWidth: 300,
          //maxHeight: 300
          );
    } catch (e) {
      debugPrint('get gallery exception : $e');
    }

    galleryImageFile = await cropImage(galleryImageFile);

    setState(() {
      _image = galleryImageFile;
    });
  }

  Future<File> cropImage(File image) async {
    try {
      image = await ImageCropper.cropImage(
        sourcePath: image.path,
        // 180x224 is the ratio of the default image .png
        aspectRatio:  CropAspectRatio(ratioX: 180, ratioY: 224),
      );
    } catch (e) {
      debugPrint('crop exception : $e');
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select an image'),
        ),
        body: Column(children: <Widget>[
          Expanded(
              flex: 1,
              child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300], width: 5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 7)),
                        child: _image == null
                            ? Center(
                            child: Text('No image selected.',
                                style: TextStyle(
                                    fontFamily: 'ActiveX', fontSize: 30)))
                            : Image.file(
                            _image), // This takes the myImage variable from the corresponding Stateful widget
                      )))),
          Stack(children: <Widget>[
            Container(
              margin: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  heroTag: 'CameraFAB',
                  onPressed: getPhoto,
                  tooltip: 'Add a photo',
                  child: Icon(Icons.add_a_photo),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: <Widget>[
                        RaisedButton(
                          child: Text(
                            'Save image',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'ActiveX',
                                color: Colors.white),
                          ),
                          color: Theme.of(context).accentColor,
                          elevation: 4.0,
                          splashColor:
                          Colors.red, // colour when in a pressed state
                          onPressed: () => Navigator.pop(context,
                              _image), // pop to calling route, returning selected image
                        ),
                        RaisedButton(
                          child: Text(
                            'Remove image',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'ActiveX',
                                color: Colors.white),
                          ),
                          color: Colors.blue,
                          elevation: 4.0,
                          splashColor:
                          Colors.red, // colour when in a pressed state
                          onPressed: () => Navigator.pop(context, File('')),
                        ),
                      ],
                    ))),
            Container(
              margin: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: 'GalleryFAB',
                  onPressed: getGallery,
                  tooltip: 'Select picture',
                  child: Icon(Icons.photo_album),
                ),
              ),
            ),
          ])
        ]));
  }
}
