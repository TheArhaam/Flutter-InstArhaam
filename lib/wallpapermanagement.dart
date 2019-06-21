import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  AddWallpaperState(this.details) {
    initUsers();
    initWallpapers();
  }

//For initializing the wallpaper list from the Database
  initWallpapers() {
    String
        currentUser; //Cut email of the user whose images are currently being added to the wallpaperlist
    // String tempdpurl = '',
    //     tempuemail = '',
    //     tempname = ''; //To fetch the user details into

    wallpaperdb.once().then((ds) {
      Map emailds = ds.value; //DataSnapchat at the Cut email
      emailds.forEach((key, value) {
        currentUser = key.toString(); //Setting the current user

        Map imagesds =
            value; //DataSnapshot at the Images child of the current user
        imagesds.forEach((key, value) {
          if (key.toString() == 'Images') {

            Map elementsds = value;
            elementsds.forEach((key, value) {
              Map detailsds = value;
              detailsds.forEach((key, value) {
                if (key.toString() == 'imageurl') {
                  tempurl = value.toString();
                } else if (key.toString() == 'txt') {
                  temptxt = value.toString();
                } else if (key.toString() == 'owner') {
                  tempowner = value.toString();
                } else if (key.toString() == 'Liked by') {
                  Map likedds = value;
                  if (likedds.containsKey(details.userEmail
                      .substring(0, details.userEmail.length - 4))) {
                    //CHECKING IF THE LOGGED IN USER LIKED THIS IMAGE, DO NOT CHANGE ITS CORRECT
                    templiked = true;
                  } else {
                    templiked = false;
                  }
                }
              });
              wallpaperlist.add(new Wallpaper.ifImage(
                  Image.network(
                    tempurl,
                  ),
                  Text(temptxt),
                  tempowner,
                  templiked,
                  userlist[count].dpUrl,
                  userlist[count].userEmail,
                  userlist[count].userName));
              count++;
              templiked = false;
              //THE ABOVE IMPLEMENTATION IF FOR EVERY SINGLE IMAGE IN THE DATABASE OF ALL USERS
              //START THE IMPLEMENTATION OF FOLLOWERS AND FOLLOWING TO DISPLAY ONLY LOGGEDIN USERS IMAGES AND THE FOLLOWING USERS IMAGES
            });
          }
        });
      });
      setState(() {});
    });
  }

  initUsers() {
    wallpaperdb.once().then((ds) {
      Map emailsds = ds.value;
      emailsds.forEach((key, value) async {
        // tempemail = key.toString();
        Map udds = value;
        udds.forEach((key, value) {
          if (key.toString() == 'UserDetails') {
            // tempdpurl = value;
            Map detailsds = value;
            detailsds.forEach((key, value) {
              if (key.toString() == 'photoUrl') {
                tempdpurl = value;
              } else if (key.toString() == 'userEmail') {
                tempemail = value;
              } else if (key.toString() == 'userName') {
                tempuname = value;
              }
            });
          }
        });
        userlist.add(UserDisplayDetails(tempdpurl, tempemail, tempuname));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                await dialogForUsers(context);
                setState(() {});
                //USERS ARE INITIALIZED ONLY ONCE WHEN CONSTRUCTOR IS CALLED
                //LOOK INTO IT
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Icon(Icons.contacts), Text('  View Users')],
              ),
            ),
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
                  onPressed: () {
                    Wallpaper w4 = new Wallpaper(
                        selectedImageFile,
                        imageTitle,
                        details.userEmail
                            .substring(0, details.userEmail.length - 4),
                        details.photoUrl,
                        details.userEmail,
                        details.userName);
                    uploadImage(w4, selectedImageFile);
                    wallpaperlist.add(w4);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.cloud_upload),
                      Text(' Upload')
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
  }
}
