import 'dart:io';

import 'package:flutter/material.dart';
import 'login.dart';
import 'wallpaper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class AddWallpaper extends StatefulWidget {
  final UserDetails details;

  AddWallpaper(this.details);

  @override
  State<StatefulWidget> createState() {
    return AddWallpaperState(details);
  }
}

class AddWallpaperState extends State<AddWallpaper> {
  final UserDetails details;

  List<Wallpaper> wallpaperlist = List();
  String tempurl = '', temptxt = '';
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');
  AddWallpaperState(this.details) {
    initWallpapers();
  }

  initWallpapers() {
    wallpaperdb.once().then((ds) {
      Map emailds = ds.value;
      emailds.forEach((key, value) {
        print('${key}');
        if (key ==
            details.userEmail.substring(0, details.userEmail.length - 4)) {
          Map elementsds = value;
          elementsds.forEach((key, value) {
            Map detailsds = value;
            detailsds.forEach((key, value) {
              print('${value}');
              if (key.toString() == 'imageurl') {
                tempurl = value.toString();
              } else if (key.toString() == 'txt') {
                temptxt = value.toString();
              }
            });
            wallpaperlist.add(new Wallpaper.ifImage(
                Image.network(
                  tempurl,
                ),
                Text(temptxt)));
          });
        }
      });

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 170,
          child: RaisedButton(
              onPressed: () {
                // wallpaperlist.add(w4);
                dialogForInput(context);
                setState(() {});
              },
              child: Row(
                children: <Widget>[
                  Icon(Icons.add_a_photo),
                  Text('  Upload Image'),
                ],
              )),
        ),
        WallpaperListWidget(wallpaperlist),
      ],
    );
  }

  dialogForInput(BuildContext context) {
    File selectedImageFile;
    Text imageTitle;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    selectedImageFile = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                  },
                  child: Text('Select Image'),
                ),
                Text('Enter Caption: '),
                TextField(
                  enabled: true,
                  maxLength: 40,
                  obscureText: false,
                  maxLines: 2,
                  expands: false,
                  maxLengthEnforced: true,
                  onChanged: (String title) {
                    imageTitle =
                        Text(title, style: TextStyle(color: Colors.white));
                  },
                ),
                RaisedButton(
                  onPressed: () {
                    Wallpaper w4 = new Wallpaper(selectedImageFile, imageTitle);
                    uploadImage(w4, selectedImageFile);
                    wallpaperlist.add(w4);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text('Upload'),
                )
              ],
            ),
          );
        });
  }

  Future uploadImage(Wallpaper wallpaper, File selectedImageFile) async {
    final StorageReference str = FirebaseStorage.instance
        .ref()
        .child('Wallpapers')
        .child(details.userEmail);
    StorageUploadTask uploadTask =
        str.child(wallpaper.txt.data).putFile(selectedImageFile);
    String downloadURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    FirebaseWallpaper fwallpaper =
        new FirebaseWallpaper(downloadURL, wallpaper.txt.data);
    wallpaperdb
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child(fwallpaper.txt)
        .set(fwallpaper.getJSON());
  }
}
