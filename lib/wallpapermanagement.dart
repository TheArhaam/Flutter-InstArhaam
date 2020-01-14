import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/userlist.dart';
import 'wallpaper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class Management extends StatefulWidget {
  final UserDetails details;

  Management(this.details);

  @override
  State<StatefulWidget> createState() {
    return ManagementState(details);
  }
}

class ManagementState extends State<Management> {
  List<UserDisplayDetails> userlist = List();
  final UserDetails details;
  int count = 0;
  List<Wallpaper> wallpaperlist = List();
  String tempurl = '',
      temptxt = '',
      tempowner = '',
      tempdpurl = '',
      tempemail = '',
      tempuname = '';
  bool templiked = false;
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');

  ManagementState(this.details) {
    // initUsers();
    // initWallpapers();
    // userlist = initUsers();
    // wallpaperlist = initWallpapers(details, userlist);

    //NEW IMPLEMENTATION
    wallpaperdb.onChildAdded.listen(dbadd);
    wallpaperdb.onChildRemoved.listen(dbremove);
  }

  dbadd(Event event) {
    //For userlist
    var user = new UserDisplayDetails.fromJSON(event.snapshot.value);
    userlist.add(user);
    setState(() {});
    //For wallpaperlist
    var userdb = FirebaseDatabase.instance
        .reference()
        .child('Wallpapers')
        .child(user.userEmail.substring(0, user.userEmail.length - 4))
        .child('Images');
    userdb.onChildAdded.listen((Event uevent) {
      var wallp = new Wallpaper.fromJSON(uevent.snapshot.value, user);
      wallpaperlist.add(wallp);
      setState(() {});
    });
  }

  dbremove(Event event) {
    var user = new UserDisplayDetails.fromJSON(event.snapshot.value);
    var userdb = FirebaseDatabase.instance
        .reference()
        .child('Wallpapers')
        .child(user.userEmail.substring(0, user.userEmail.length - 4))
        .child('Images');
    userdb.onChildRemoved.listen((Event uevent) {
      wallpaperlist.removeWhere((w) {
        if (w.txt == (new Wallpaper.fromJSON(event.snapshot.value, user).txt)) {
          return true;
        }
        return false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height - 128.0;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // RaisedButton(
            //   onPressed: () async {
            //     // await dialogForUsers(context);
            //     showDialog(
            //       context: context,
            //       builder: (BuildContext context) => UserListPage(),
            //     );
            //     setState(() {});
            //     //USERS ARE INITIALIZED ONLY ONCE WHEN CONSTRUCTOR IS CALLED
            //     //LOOK INTO IT
            //   },
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: <Widget>[Icon(Icons.contacts), Text('  View Users')],
            //   ),
            // ),
            RaisedButton(
                onPressed: () {
                  dialogForInput(context);
                  setState(() {});
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add_a_photo),
                    Text('  Upload Image'),
                  ],
                )),
          ],
        ),
        WallpaperListWidget(wallpaperlist, details),
      ],
    );
  }

  dialogForUsers(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height - 280.0;
    final double wsize = MediaQuery.of(context).size.width - 150.0;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              elevation: 10,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(width: 5, color: Color(0xFF1b1b1b))),
              backgroundColor: Color(0xFF484848),
              title: Text('USERS'),
              content: Container(
                width: wsize,
                height: hsize,
                child: ListView(
                    children: userlist
                        .map((element) => Card(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    element.dpUrl,
                                    height: 35,
                                  ),
                                ),
                                Text(
                                  element.userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.plus,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              ],
                            )))
                        .toList()),
              ));
        });
  }

  dialogForInput(BuildContext context) {
    //CREATE A SEPARATE STATE FOR THIS SO YOU CAN IMPLEMENT SPINNERS FOR LOADING
    //THIS IS IMPORTANT
    bool spinnervisibility = false;
    File selectedImageFile;
    Text imageTitle;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 10,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(width: 5, color: Color(0xFF1b1b1b))),
            backgroundColor: Color(0xFF484848),
            title: Text('Upload Image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    selectedImageFile = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.filter),
                      Text(' Select Image')
                    ],
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
                    imageTitle =
                        Text(title, style: TextStyle(color: Colors.white));
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
                        details.userEmail
                            .substring(0, details.userEmail.length - 4),
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
            ),
          );
        });
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
