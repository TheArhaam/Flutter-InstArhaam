import 'dart:io';

import 'package:flutter/material.dart';

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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                element.txt.data,
                                style: TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite_border),
                                onPressed: () {},
                              )
                            ],
                          )
                        ],
                      ),
                      // margin: EdgeInsets.all(10.0),
                    ),
              )
              .toList()),
    );
  }
}
