import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/userinformation.dart';

class Wallpaper {
  Image img;
  String imglink;
  Text txt;
  String owner;
  String photoUrl;
  String userEmail;
  String userName;
  bool liked;

  Wallpaper(File img, Text txt, String owner, String photoUrl, String userEmail,
      String userName) {
    this.img = Image.file(img);
    this.txt = txt;
    this.owner = owner;
    this.photoUrl = photoUrl;
    this.userEmail = userEmail;
    this.userName = userName;
    liked = false;
  }

  Wallpaper.ifImage(Image img, Text txt, String owner, bool liked,
      String photoUrl, String userEmail, String userName) {
    this.img = img;
    this.txt = txt;
    this.owner = owner;
    this.liked = liked;
    this.photoUrl = photoUrl;
    this.userEmail = userEmail;
    this.userName = userName;
  }

  Wallpaper.fromJSON(Map imgdetails, UserDisplayDetails user) {
    this.img = Image.network(imgdetails['imageurl']);
    this.imglink = imgdetails['imageurl'];
    this.txt = Text(imgdetails['txt']);
    this.owner = imgdetails['owner'];
    if (imgdetails['Liked by'][this.owner].toString() == 'true') {
      this.liked = true;
    } else if (imgdetails['Liked by'][this.owner] == null) {
      this.liked = false;
    }
    this.photoUrl = user.dpUrl;
    this.userEmail = user.userEmail;
    this.userName = user.userName;
  }
}

class FirebaseWallpaper {
  String imageurl;
  String txt;
  String owner;

  FirebaseWallpaper(String imageurl, String txt, String owner) {
    this.imageurl = imageurl;
    this.txt = txt;
    this.owner = owner;
  }
  getJSON() {
    return {
      'imageurl': '${imageurl}',
      'txt': '${txt}',
      'owner': '${owner}',
      'Liked by': {'default': 'true'}
    };
  }
}

class WallpaperListWidget extends StatefulWidget {
  final List<Wallpaper> wallpaperlist;
  final UserDetails details;
  const WallpaperListWidget(this.wallpaperlist, this.details);
  @override
  State<StatefulWidget> createState() {
    return WallpaperListState(wallpaperlist, details);
  }
}

class WallpaperListState extends State<WallpaperListWidget> {
  List<Wallpaper> wallpaperlist;
  final UserDetails details;
  Icon sicon;
  Icon favicon = Icon(Icons.favorite);
  Icon favbicon = Icon(Icons.favorite_border);
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');

  WallpaperListState(this.wallpaperlist, this.details) {
    sicon = favbicon;
  }

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height - 128.0;
    return Container(
      height: hsize,
      child: ListView(
          addAutomaticKeepAlives: true,
          children: wallpaperlist
              .map(
                (element) => Card(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                element.photoUrl,
                                height: 30,
                              ),
                              //THIS DISPLAYS THE LOGGED IN USERS INFO
                              //CHANGE IT AND SAVE THE OWNER INFO ON FIREBASE AS WELL
                            ),
                          ),
                          Text(element.userName,
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                      //IMAGE
                      FadeInImage.assetNetwork(
                        image: element.imglink,
                        placeholder: 'assets/Loading.gif',
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Text(element.txt.data,
                                      style: TextStyle(color: Colors.white)))),
                          Row(
                            children: <Widget>[
                              IconButton(
                                splashColor: Colors.white,
                                icon: checkFav(element),
                                onPressed: () {
                                  setState(() {
                                    if (element.liked == false) {
                                      element.liked = true;
                                      wallpaperdb
                                          .child(element.owner)
                                          .child('Images')
                                          .child(element.txt.data)
                                          .child('Liked by')
                                          .child(details.userEmail.substring(
                                              0, details.userEmail.length - 4))
                                          .set(true);
                                    } else if (element.liked == true) {
                                      element.liked = false;
                                      wallpaperdb
                                          .child(element.owner)
                                          .child('Images')
                                          .child(element.txt.data)
                                          .child('Liked by')
                                          .child(details.userEmail.substring(
                                              0, details.userEmail.length - 4))
                                          .remove();
                                    }
                                  });
                                },
                              ),
                              Theme(
                                data: Theme.of(context)
                                    .copyWith(cardColor: Color(0xFF484848)),
                                child: PopupMenuButton(
                                  onSelected: (var choice) {
                                    if (choice == 'Delete') {
                                      wallpaperdb
                                          .child(element.owner)
                                          .child('Images')
                                          .child(element.txt.data)
                                          .remove();

                                      FirebaseStorage.instance
                                          .ref()
                                          .child('Wallpapers')
                                          .child(element.owner)
                                          .child(element.txt.data)
                                          .delete();

                                      wallpaperlist.remove(element);
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(Icons.menu),
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuItem>[
                                      PopupMenuItem(
                                        value: 'Delete',
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ];
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList()),
    );
  }

  Widget checkFav(var element) {
    if (element.liked == true) {
      return favicon;
    } else {
      return favbicon;
    }
  }
}
