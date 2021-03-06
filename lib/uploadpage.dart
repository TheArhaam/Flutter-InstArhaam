import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/wallpaper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

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
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');
  bool spinnervisibility = false;
  File selectedImageFile;
  var image;
  double uploadVal = 0.0;

  UploadPageState(UserDetails details) {
    // image = Image.asset('assets/UploadPageDefault.jpg');
    this.details = details;
  }

  @override
  Widget build(BuildContext context) {
    final double scheight = MediaQuery.of(context).size.height;
    final double scwidth = MediaQuery.of(context).size.width;
    var containerHeight =
        (scheight - kToolbarHeight - kBottomNavigationBarHeight - 24) * 0.55;
    Text imageTitle;

    return ListView(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: containerHeight,
                width: scwidth,
                decoration: BoxDecoration(
                    border: Border.all(width: 5),
                    image: DecorationImage(
                      image: AssetImage('assets/UploadPageDefault.jpg'),
                      fit: BoxFit.cover,
                    )),
                child: image,
              ),
            ),

            //SELECT IMAGE BUTTON
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(width: 1)),
              splashColor: Theme.of(context).primaryColor,
              highlightColor: Theme.of(context).primaryColor,
              onPressed: () async {
                selectedImageFile =
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                image = Image.file(
                  selectedImageFile,
                  height: containerHeight,
                );
                // if (image == null) {
                //   image = Image.asset(
                //     'assets/UploadPageDefault.jpg',
                //     fit: BoxFit.fitWidth,
                //   );
                // }
                setState(() {});
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.filter,
                    color: Colors.white,
                  ),
                  Text(
                    ' Select Image',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            Text(
              'Enter image title: ',
              style: TextStyle(color: Colors.white, height: 1.5, fontSize: 20),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  enabled: true,
                  maxLength: 15,
                  obscureText: false,
                  maxLines: 1,
                  expands: false,
                  maxLengthEnforced: true,
                  onChanged: (String title) {
                    imageTitle =
                        Text(title, style: TextStyle(color: Colors.white));
                  },
                )),

            //UPLOAD BUTTON
            RaisedButton(
              onPressed: () async {
                setState(() {
                  spinnervisibility = true;
                });
                Wallpaper w4 = new Wallpaper(
                    selectedImageFile,
                    imageTitle,
                    details.userEmail
                        .substring(0, details.userEmail.length - 4),
                    details.photoUrl,
                    details.userEmail,
                    details.userName);
                await uploadImage(w4, selectedImageFile);
                spinnervisibility = false;
                setState(() {});
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.cloud_upload),
                  Text(' Upload '),
                  Visibility(
                    visible: spinnervisibility,
                    child:
                        //   SpinKitFadingFour(
                        //     size: 20,
                        //     duration: Duration(seconds: 1),
                        //     color: Colors.white,
                        //   ),
                        Container(
                            height: 20,
                            width: 20,
                            child: LiquidCircularProgressIndicator(
                              borderWidth: 1,
                              borderColor: Colors.white,
                              backgroundColor: Colors.white,
                              value: uploadVal,
                            )),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Future uploadImage(Wallpaper wallpaper, File selectedImageFile) async {
    //GETTING IMAGE HEIGHT & WIDTH
    var imageHeight;
    var imageWidth;
    Image.file(selectedImageFile)
        .image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((info, val) {
      imageHeight = info.image.height;
      imageWidth = info.image.width;
    }));

    //UPLOADING IMAGE TO FIREBASE STORAGE
    final StorageReference str = FirebaseStorage.instance
        .ref()
        .child('Wallpapers')
        .child(details.userEmail.substring(0, details.userEmail.length - 4));
    StorageUploadTask uploadTask =
        str.child(wallpaper.txt.data).putFile(selectedImageFile);

    uploadTask.events.listen((event) {
      uploadVal = event.snapshot.bytesTransferred.toDouble() /
          event.snapshot.totalByteCount.toDouble();
      print('PROGRESS: ${uploadVal}');
      setState(() {});
    });

    String downloadURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    //ADDING IMAGE TO REALTIMEDATABASE
    FirebaseWallpaper fwallpaper = new FirebaseWallpaper(downloadURL,
        wallpaper.txt.data, wallpaper.owner, imageHeight, imageWidth);
    await wallpaperdb
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('Images')
        .child(fwallpaper.txt)
        .set(fwallpaper.getJSON());

    //INCREMENTING POSTS
    var posts;
    await wallpaperdb
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('UserDetails')
        .child('posts')
        .once()
        .then((snapshot) {
      posts = int.parse(snapshot.value);
    });
    posts++;
    await wallpaperdb
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('UserDetails')
        .child('posts')
        .set(posts.toString());
    return;
  }
}
