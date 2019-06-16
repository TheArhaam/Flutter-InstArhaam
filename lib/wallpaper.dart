import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Wallpaper {
  Image img;
  Text txt;

  Wallpaper(File img, Text txt) {
    this.img = Image.file(img);
    this.txt = txt;
  }

  Wallpaper.ifImage(Image img, Text txt) {
    this.img = img;
    this.txt = txt;
  }
}

class FirebaseWallpaper {
  String imageurl;
  String txt;

  FirebaseWallpaper(String imageurl, String txt) {
    this.imageurl = imageurl;
    this.txt = txt;
  }
  getJSON() {
    return {'imageurl': '${imageurl}', 'txt': '${txt}'};
  }
}

class WallpaperListWidget extends StatelessWidget {
  final List<Wallpaper> wallpaperlist;

  WallpaperListWidget(this.wallpaperlist);
  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height - 128.0;
    return Container(
      height: hsize,
      child: ListView(
          children: wallpaperlist
              .map(
                (element) => Card(
                      child: Column(
                        children: <Widget>[
                          element.img,
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                      child: Text(element.txt.data,
                                          style:
                                              TextStyle(color: Colors.white)))),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.favorite_border),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.menu),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // margin: EdgeInsets.all(10.0),
                    ),
              )
              .toList()),
    );
  }
}
