import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_flutter/userinformation.dart';
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
    return Column(
      children: <Widget>[
        WallpaperListWidget(wallpaperlist, details),
      ],
    );
  }
}
