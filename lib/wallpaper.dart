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

class WallpaperListWidget extends StatefulWidget {
  final List<Wallpaper> wallpaperlist;
  const WallpaperListWidget(this.wallpaperlist);
  @override
  State<StatefulWidget> createState() {
    return WallpaperListState(wallpaperlist);
  }
}

class WallpaperListState extends State<WallpaperListWidget> {
  final List<Wallpaper> wallpaperlist;
  Icon favicon;

  WallpaperListState(this.wallpaperlist) {
    favicon = Icon(Icons.favorite_border);
  }

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
                                    icon: favicon,
                                    onPressed: () {
                                      setState(() {
                                        favicon = Icon(Icons.favorite);

                                      //ADD A NEW PROPERTY TO THE DATABASE FOR EACH IMAGE
                                      //A CHILD WITH KEY=>EMAIL VALUE=>TRUE/FALSE
                                      //THIS WILL TELL US IF THE KEY(EMAIL) HAS LIKED THE IMAGE OR NOT
                                      //ACCORDINGLY WE CAN DISPLAY THE ICON AS ONLY BORDER OR FILLED

                                      });
                                    },
                                  ),
                                  Theme(
                                    data: Theme.of(context)
                                        .copyWith(cardColor: Color(0xFF484848)),
                                    child: PopupMenuButton(
                                      icon: Icon(Icons.menu),
                                      itemBuilder: (BuildContext context) {
                                        return <PopupMenuItem>[
                                          PopupMenuItem(
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
                      // margin: EdgeInsets.all(10.0),
                    ),
              )
              .toList()),
    );
  }
}
