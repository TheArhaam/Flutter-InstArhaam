import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/wallpaper.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class MainFeed extends StatefulWidget {
  final UserDetails details;
  const MainFeed(this.details);
  @override
  State<StatefulWidget> createState() {
    return MainFeedState(details);
  }
}

class MainFeedState extends State<MainFeed> {
  List<UserDisplayDetails> userlist = List();
  List<Wallpaper> wallpaperlist = List();
  final UserDetails details;
  Icon sicon;
  Icon favicon = Icon(Icons.favorite);
  Icon favbicon = Icon(Icons.favorite_border);
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');

  MainFeedState(this.details) {
    sicon = favbicon;
    wallpaperdb.onChildAdded.listen(dbadd);
    wallpaperdb.onChildChanged.listen(dbremove);
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
    print('Called');
    var user = new UserDisplayDetails.fromJSON(event.snapshot.value);
    var userdb = FirebaseDatabase.instance
        .reference()
        .child('Wallpapers')
        .child(user.userEmail.substring(0, user.userEmail.length - 4))
        .child('Images');
    userdb.onChildRemoved.listen((Event uevent) {
      print('Reached');
      wallpaperlist.removeWhere((w) {
        if (w.txt == (new Wallpaper.fromJSON(event.snapshot.value, user).txt)) {
          print(w.txt);
          return true;
        }
        return false;
      });
      print(wallpaperlist);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height;
    final double wsize = MediaQuery.of(context).size.width;
    double maxheight =
        (hsize - kToolbarHeight - kBottomNavigationBarHeight - 24) * 0.8;
    double minheight =
        (hsize - kToolbarHeight - kBottomNavigationBarHeight - 24) * 0.4;

    return Container(
      height: hsize - kBottomNavigationBarHeight - kToolbarHeight - 24,
      child: ListView(
          addAutomaticKeepAlives: true,
          children: wallpaperlist.map(
            (element) {
              double val = 0.0;
              bool visibility = true;
              bool loadingVisibility = true;

              //Finding the newheight obtained when image is reduced due to width constraint of card
              var reqwidth = wsize - 20;
              var newheight =
                  (element.imageHeight * reqwidth) / element.imageWidth;

              if (newheight < maxheight) {
                minheight = newheight;
              } else {
                minheight = maxheight;
              }
              return Card(
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
                    //For implementing progressbar along with FadeInImage
                    //FadInImage doesnt provide 'loadingBuilder'
                    //ImageFade adds 'loadingBuilder' and other features on top of FadeInImage
                    //VERSION-1
                    // Stack(
                    //   children: <Widget>[
                    //     Center(child: CircularProgressIndicator()),
                    //     Center(
                    //       child: FadeInImage.memoryNetwork(
                    //         placeholder: kTransparentImage,
                    //         image: element.imglink,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //VERSION-2
                    // ImageFade(
                    //   image: NetworkImage(element.imglink),
                    //   placeholder: Image.asset('assets/Loading.gif'),
                    //   loadingBuilder: (context, widget, event) {
                    //     if (event == null) {
                    //       return widget;
                    //     }
                    //     double val;
                    //     if (null == event.expectedTotalBytes) {
                    //       val = 0.0;
                    //     } else {
                    //       val = event.cumulativeBytesLoaded /
                    //           event.expectedTotalBytes;
                    //     }
                    //     return LinearProgressIndicator(
                    //       backgroundColor: Colors.white,
                    //       value: val,
                    //     );
                    //   },
                    // ),
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
                            Image.network(
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
                            ),
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
              );
            },
          ).toList()),
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
