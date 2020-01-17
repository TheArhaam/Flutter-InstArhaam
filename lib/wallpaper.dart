//CONTAINS DEFINITION FOR Wallpaper & FirebaseWallpaper

import 'dart:io';
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
  int imageHeight;
  int imageWidth;

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
    this.imageHeight = int.parse(imgdetails['imageHeight']);
    this.imageWidth = int.parse(imgdetails['imageWidth']);
    this.photoUrl = user.dpUrl;
    this.userEmail = user.userEmail;
    this.userName = user.userName;
  }
}

class FirebaseWallpaper {
  String imageurl;
  String txt;
  String owner;
  int imageHeight;
  int imageWidth;

  FirebaseWallpaper(String imageurl, String txt, String owner, int imageHeight,
      int imageWidth) {
    this.imageurl = imageurl;
    this.txt = txt;
    this.owner = owner;
    this.imageHeight = imageHeight;
    this.imageWidth = imageWidth;
  }
  getJSON() {
    return {
      'imageurl': '${imageurl}',
      'txt': '${txt}',
      'owner': '${owner}',
      'imageHeight': '${imageHeight}',
      'imageWidth': '${imageWidth}',
      'Liked by': {'default': 'true'}
    };
  }
}

