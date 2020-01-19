import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/wallpaper.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class PostPop extends StatefulWidget {
  Wallpaper element;
  UserDetails details;
  PostPop(this.element, this.details);
  @override
  State<StatefulWidget> createState() {
    return PostPopState(element, details);
  }
}

class PostPopState extends State<PostPop> {
  UserDetails details;
  Wallpaper element;
  double hsize;
  double wsize;
  double maxheight;
  double minheight;
  Icon favicon = Icon(Icons.favorite);
  Icon favbicon = Icon(Icons.favorite_border);
  PostPopState(this.element, this.details);
  @override
  Widget build(BuildContext context) {
    hsize = MediaQuery.of(context).size.height;
    wsize = MediaQuery.of(context).size.width;
    maxheight =
        (hsize - kToolbarHeight - kBottomNavigationBarHeight - 24) * 0.8;
    minheight =
        (hsize - kToolbarHeight - kBottomNavigationBarHeight - 24) * 0.4;
    return AnimatedContainer(
      
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Theme.of(context).primaryColor,
              child: buildCard(),
            )));
  }

  Widget buildCard() {
    var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');

    double val = 0.0;
    bool visibility = true;
    bool loadingVisibility = true;
    bool deleteEnabled = false;

    //Checking if user is the owner of the image
    if (details.userEmail.substring(0, details.userEmail.length - 4) ==
        element.owner) {
      deleteEnabled = true;
    }

    //Finding the newheight obtained when image is reduced due to width constraint of card
    var reqwidth = wsize - 20;
    var newheight = (element.imageHeight * reqwidth) / element.imageWidth;

    if (newheight < maxheight) {
      minheight = newheight;
    } else {
      minheight = maxheight;
    }
    return Container(
        color: Colors.black,
        child: Card(
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  Text(element.userName, style: TextStyle(color: Colors.white))
                ],
              ),
              //IMAGE
              //VERSION-3
              Container(
                  constraints: BoxConstraints(
                    minHeight: minheight,
                    maxHeight: minheight,
                  ),
                  //Using stack because returning LiquidCircularProgressIndicator()
                  //Takes up the entire container
                  //Within stack we can place it anywhere
                  child: Stack(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            // border: Border(
                            //     top: BorderSide(
                            //         color: Theme.of(context).primaryColor,
                            //         width: 5),
                            //     bottom: BorderSide(
                            //         color: Theme.of(context).primaryColor,
                            //         width: 5)),
                          ),
                          child: Center(
                              child: Image.network(
                            element.imglink,
                            loadingBuilder: (context, child, event) {
                              if (event == null) {
                                return child;
                              }
                              val = event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes;
                              if (val == 1) {
                                return child;
                              } else if (val < 1) {
                                //Using Center to make sure the ProgressIndicator is
                                //in the center of the stack
                                return Center(
                                    //Using SizedBox to maintain the size of the ProgressIndicator
                                    child: SizedBox(
                                  height: reqwidth * 0.2,
                                  width: reqwidth * 0.2,
                                  child: LiquidCircularProgressIndicator(
                                    borderColor: Colors.white,
                                    borderWidth: 2,
                                    direction: Axis.vertical,
                                    value: val,
                                    backgroundColor: Colors.white,
                                  ),
                                ));
                              }
                            },
                          ))),
                    ],
                  )),

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
                          enabled: deleteEnabled,
                          onSelected: (var choice) async {
                            if (choice == 'Delete') {
                              await FirebaseStorage.instance
                                  .ref()
                                  .child('Wallpapers')
                                  .child(element.owner)
                                  .child(element.txt.data)
                                  .delete();

                              await wallpaperdb
                                  .child(element.owner)
                                  .child('Images')
                                  .child(element.txt.data)
                                  .remove();

                              //DECREMENTING POSTS
                              var posts;
                              await wallpaperdb
                                  .child(details.userEmail.substring(
                                      0, details.userEmail.length - 4))
                                  .child('UserDetails')
                                  .child('posts')
                                  .once()
                                  .then((snapshot) {
                                posts = int.parse(snapshot.value);
                              });
                              posts--;
                              await wallpaperdb
                                  .child(details.userEmail.substring(
                                      0, details.userEmail.length - 4))
                                  .child('UserDetails')
                                  .child('posts')
                                  .set(posts.toString());

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
        ));
  }

  Widget checkFav(var element) {
    if (element.liked == true) {
      return favicon;
    } else {
      return favbicon;
    }
  }
}
