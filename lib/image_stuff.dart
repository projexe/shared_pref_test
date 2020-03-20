import 'dart:io';
import 'package:flutter/material.dart';
import 'route_imagepicker.dart' as _routeImagePicker;


/// definition of callback for returning a file
typedef void ImageFileCallback(File imageFile);

///Stateless Framed photo widget displaying a default image depending on the risk type.
///The photo has a selection button which enables a photograph to be added either
///from the internal camera or the picture gallery
class AFIPhotoFrame extends StatefulWidget {
  final String imageFileRef;
  final bool isEditable;
  final BoxFit fit;
  final double width;
  final double height;
  final ImageFileCallback onImageChanged;
  //final String imageUri;

  AFIPhotoFrame(
      this.imageFileRef,
  {
        this.isEditable = false,
        this.width = 75, // default
        this.height,
        this.fit,
        this.onImageChanged,
      });

  @override
  _AFIPhotoFrameState createState() {
    // the @override return type is State. As long as the return type is a class extending State then everything is cool
    return _AFIPhotoFrameState();
  }
}

class _AFIPhotoFrameState extends State<AFIPhotoFrame> {
  static const String classTag = '_AFIPhotoFrameState';
  File _myImageFile;
  Image iw1, iw2;
  //String _riskType;

//  @override
//  void didChangeDependencies() {
//    const String tag = 'didChangeDependencies()';
//    debugPrint('$classTag.$tag');
//    super.didChangeDependencies();
//    _policy = RepositoryService.of(context).repository.policy(widget.policyRef);
//  }

  @override
  Widget build(BuildContext context) {
    var _isPetImageExists = widget.imageFileRef.isNotEmpty ?? false;
    _myImageFile = null;
    if (_isPetImageExists) {
      _myImageFile = File(widget.imageFileRef);
      if (!_myImageFile.existsSync()) {
        _myImageFile = null;
      }
    }

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(color: Colors.grey[300], width: 5),
                  bottom: BorderSide(color: Colors.grey[300], width: 5))),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 7)),
              child: PetImage(
                imageFile: _myImageFile,
                //riskType: _policy?.pet?.riskType,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
              )), // This takes the myImage variable from the corresponding Stateful widget
        ),
        widget.isEditable
            ? RawMaterialButton(
          constraints: BoxConstraints.tight(Size(30, 30)),
          onPressed: () async {
            //selects a photo. If a picture is selected it calls setState() to update the state and rebuild the widget
            var _newImage =
            await _navigateAndSelectPhoto(context, _myImageFile);
            widget.onImageChanged(
                _newImage); // call onImageChanged callback passing new image
          },
          child: new Icon(
            Icons.photo_camera,
            color: Colors.white,
            size: 20.0,
          ),
          shape: new CircleBorder(),
          elevation: 2.0,
          fillColor: Colors.grey[700],
        )
            : Container(
          constraints: BoxConstraints.tight(Size(30, 30)),
        ),
      ],
    );
  }

  // A method that launches the Image Picker and awaits the result from
  // Navigator.pop! Returns the filename of any image selected or an empty string
  Future<File> _navigateAndSelectPhoto(
      BuildContext context, File imageFile) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    File result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _routeImagePicker.RouteImagePicker(
          imageFile: imageFile,
        ),
        settings: RouteSettings(name: "Image picker route"),
      ),
    );
    // when the stateImageFile is updates, this triggers setState to rebuild the widget
    if (this.mounted) {
      setState(() {
        _myImageFile = result ?? _myImageFile;
      });
    } else
      _myImageFile = result ?? _myImageFile;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result! (uses method cascade .. notation)
    //Scaffold.of(context)
    //  ..removeCurrentSnackBar()
    //  ..showSnackBar(SnackBar(content: Text("$result")));

    return _myImageFile;
  }
}

/// Builds widget returning an image asset either displaying the image contained
/// within the imageFile, or a default image (dog/cat/horse/rider) depending on
/// the riskType string.
class PetImage extends StatelessWidget {
  final File imageFile;
  //final RiskType riskType;
  final double width;
  final double height;
  final BoxFit fit;
  PetImage(
      {this.imageFile,
        //@required this.riskType,
        this.height,
        this.width,
        this.fit});

  @override
  Widget build(BuildContext context) {
    if (!isValidPath(imageFile))
      return Text("Invalid image path");
    else
      return Image.file(imageFile,
          width: width ?? 75, height: height ?? null, fit: fit ?? BoxFit.fill);
  }


  // Return true if the path of the _imageFile parameter contains a valid path
  bool isValidPath(File _imageFile) {
    if (_imageFile == null) return false;
    if (_imageFile.path.trim().isEmpty) return false;
    return true;
  }


}
