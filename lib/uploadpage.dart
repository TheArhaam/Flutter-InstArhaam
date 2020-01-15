import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/wallpaper.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  UserDetails details;
  UploadPage(UserDetails details) {
    this.details = details;
  }
  @override
  State<StatefulWidget> createState() {
    return UploadPageState(details);
  }
}

class UploadPageState extends State<UploadPage> {
  UserDetails details;
  Image image;
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');
  bool spinnervisibility;
  File selectedImageFile;

  UploadPageState(UserDetails details) {
    image = Image.asset('assets/UploadPageDefault.jpg', fit: BoxFit.fitWidth);
    this.details = details;
  }

  @override
  Widget build(BuildContext context) {
    final double scheight = MediaQuery.of(context).size.height;
    final double scwidth = MediaQuery.of(context).size.width;
    Text imageTitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        image,
        RaisedButton(
          onPressed: () async {
            selectedImageFile =
                await ImagePicker.pickImage(source: ImageSource.gallery);
            image = Image.file(
              selectedImageFile,
              fit: BoxFit.fitWidth,
            );
            if (image == null) {
              image = Image.asset(
                'assets/UploadPageDefault.jpg',
                fit: BoxFit.fitWidth,
              );
            }
            setState(() {});
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Icon(Icons.filter), Text(' Select Image')],
          ),
        ),
        Text(
          'Enter image title: ',
          style: TextStyle(color: Colors.white, height: 1.5),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          enabled: true,
          maxLength: 15,
          obscureText: false,
          maxLines: 1,
          expands: false,
          maxLengthEnforced: true,
          onChanged: (String title) {
            imageTitle = Text(title, style: TextStyle(color: Colors.white));
          },
        ),
        RaisedButton(
          onPressed: () async {
            setState(() {
              spinnervisibility = true;
            });
            Wallpaper w4 = new Wallpaper(
                selectedImageFile,
                imageTitle,
                details.userEmail.substring(0, details.userEmail.length - 4),
                details.photoUrl,
                details.userEmail,
                details.userName);
            await uploadImage(w4, selectedImageFile);
            // wallpaperlist.add(w4);
            // setState(() {});
            Navigator.pop(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.cloud_upload),
              Text(' Upload'),
              Visibility(
                visible: spinnervisibility,
                child: SpinKitFadingFour(
                  duration: Duration(seconds: 1),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future uploadImage(Wallpaper wallpaper, File selectedImageFile) async {
    final StorageReference str = FirebaseStorage.instance
        .ref()
        .child('Wallpapers')
        .child(details.userEmail.substring(0, details.userEmail.length - 4));
    StorageUploadTask uploadTask =
        str.child(wallpaper.txt.data).putFile(selectedImageFile);
    String downloadURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    FirebaseWallpaper fwallpaper =
        new FirebaseWallpaper(downloadURL, wallpaper.txt.data, wallpaper.owner);
    wallpaperdb
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('Images')
        .child(fwallpaper.txt)
        .set(fwallpaper.getJSON());
    return;
  }
}
