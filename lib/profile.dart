import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/postpop.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/wallpaper.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class ProfilePage extends StatefulWidget {
  UserDetails details;
  ProfilePage(this.details);
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState(details);
  }
}

class ProfilePageState extends State<ProfilePage> {
  UserDetails details;
  List<Wallpaper> profileWallpaperList = List();
  var profilewallpaperdb;

  ProfilePageState(this.details) {
    profilewallpaperdb = FirebaseDatabase.instance
        .reference()
        .child('Wallpapers')
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('Images');
    profilewallpaperdb.onChildAdded.listen(dbadd);
    profilewallpaperdb.onChildRemoved.listen(dbremove);
  }

  dbadd(Event event) {
    UserDisplayDetails user = UserDisplayDetails(
        details.photoUrl, details.userEmail, details.userName);
    var wallp = new Wallpaper.fromJSON(event.snapshot.value, user);
    profileWallpaperList.add(wallp);
    setState(() {});
  }

  dbremove(Event event) {
    UserDisplayDetails user = UserDisplayDetails(
        details.photoUrl, details.userEmail, details.userName);
    var wallp = new Wallpaper.fromJSON(event.snapshot.value, user);
    profileWallpaperList.remove(wallp);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height;
    final double wsize = MediaQuery.of(context).size.width;
    double pageSize =
        (hsize - kToolbarHeight - kBottomNavigationBarHeight - 24);
    double cardHeight = (pageSize * 0.3) + 45;
    double itemHeight = pageSize / 2.5;
    double itemWidth = (wsize - 10) / 2;
    return Column(
      children: <Widget>[
        ProfileDetailsCard(details),
        Container(
          height: pageSize - cardHeight,
          child: GridView.count(
            // shrinkWrap: true,
            padding: EdgeInsets.only(right: 5, left: 5),
            childAspectRatio: (itemHeight / itemWidth),
            crossAxisCount: 2,
            children: profileWallpaperList.map((element) {
              return InkWell(
                  onTap: () async {
                    await Future.delayed(Duration(milliseconds: 200));
                    // showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) =>
                    //         PostPop(element, details));

                    //Enables custom animations for displaying the popup
                    showGeneralDialog(
                        // barrierColor: Colors.black.withOpacity(0.5),
                        transitionBuilder: (context, a1, a2, widget) {
                          return Transform.scale(
                            scale: a1.value,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: a1.value + 2, sigmaY: a1.value + 2),
                              // opacity: a1.value,
                              child: Opacity(
                                  opacity: a1.value,
                                  child: PostPop(
                                    element,
                                    details,
                                    setStateCallback1: (element) {
                                      profileWallpaperList.remove(element);
                                      setState(() {});
                                    },
                                  )),
                            ),
                          );
                        },
                        transitionDuration: Duration(milliseconds: 200),
                        barrierDismissible: true,
                        barrierLabel: '',
                        context: context,
                        pageBuilder: (context, animation1, animation2) {});
                  },
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.network(
                      element.imglink,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, event) {
                        if (event == null) {
                          return child;
                        }
                        var val = event.cumulativeBytesLoaded /
                            event.expectedTotalBytes;
                        if (val == 1) {
                          return child;
                        } else if (val < 1) {
                          //Using Center to make sure the ProgressIndicator is
                          //in the center of the stack
                          return Center(
                              //Using SizedBox to maintain the size of the ProgressIndicator
                              child: SizedBox(
                            height: itemHeight * 0.25,
                            width: itemHeight * 0.25,
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
                  )));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ProfileDetailsCard extends StatefulWidget {
  UserDetails details;
  ProfileDetailsCard(this.details);
  @override
  State<StatefulWidget> createState() {
    return ProfileDetailsCardState(details);
  }
}

class ProfileDetailsCardState extends State<ProfileDetailsCard> {
  UserDetails details;
  var userdb;
  ProfileDetailsCardState(UserDetails details) {
    this.details = details;
    userdb = FirebaseDatabase.instance
        .reference()
        .child('Wallpapers')
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('UserDetails');
    userdb.onChildChanged.listen(userdbchanged);

    userdb.once().then((snapshot) {
      this.details = UserDetails.fromJSON(snapshot.value);
    });
  }

  userdbchanged(Event event) {
    //THIS ONLY GETS THE CHANGED DATA, NOT IDEAL FOR OUR NEEDS
    // print('${event.snapshot.value}');
    // this.details = UserDetails.fromJSON(event.snapshot.value);
    print('REACHED');
    userdb.once().then((snapshot) {
      this.details = UserDetails.fromJSON(snapshot.value);
    });
    setState(() {});
  }

  TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: 30,
  );
  TextStyle textStyle2 = TextStyle(
    color: Colors.white,
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height;
    final double wsize = MediaQuery.of(context).size.width;
    final double pageHeight =
        hsize - kToolbarHeight - kBottomNavigationBarHeight - 24;

    return Container(
      child: Stack(
        children: <Widget>[
          //CARD INFO
          Container(
            height: pageHeight * 0.3,
            margin: EdgeInsets.fromLTRB(8, 45, 8, 0),
            decoration: new BoxDecoration(
              color: new Color(0xFF212121),
              shape: BoxShape.rectangle,
              borderRadius: new BorderRadius.circular(10.0),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                  offset: new Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  top: (pageHeight * 0.1) / 2, left: 15, right: 15, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //NAME
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        details.userName,
                        style: textStyle,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                String newName;
                                return AlertDialog(
                                  backgroundColor: Theme.of(context).canvasColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        width: 5,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  title: Text('Edit',style: textStyle,),
                                  content: Container(
                                      alignment: Alignment.center,
                                      height: hsize * 0.25,
                                      width: wsize * 0.5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              'Current name: ${details.userName}',style: textStyle2,),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('Enter new name: ',style: textStyle2,),
                                              Container(
                                                width: wsize * 0.25,
                                                child: TextField(
                                                  style: textStyle2,
                                                  maxLengthEnforced: true,
                                                  maxLines: 1,
                                                  maxLength: 20,
                                                  onChanged: (string) {
                                                    newName = string;
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          RaisedButton(
                                            child: Text('UPDATE NAME'),
                                            onPressed: () async {
                                              if (newName.isNotEmpty) {
                                                await userdb
                                                    .child('userName')
                                                    .set(newName);
                                                Navigator.pop(context);
                                              }
                                            },
                                          )
                                        ],
                                      )),
                                );
                              });
                        },
                      ),
                    ],
                  ),

                  //POSTS, FOLLOWERS & FOLLOWING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      //POSTS
                      FlatButton(
                        onPressed: () {},
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        splashColor: Colors.white30,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'POSTS',
                              style: textStyle2,
                            ),
                            Text(
                              details.posts.toString(),
                              style: textStyle2,
                            )
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: pageHeight * 0.06,
                        color: Colors.white,
                      ),

                      //FOLLOWERS
                      FlatButton(
                        onPressed: () {},
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        splashColor: Colors.white30,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'FOLLOWERS',
                              style: textStyle2,
                            ),
                            Text(
                              details.followers.toString(),
                              style: textStyle2,
                            )
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: pageHeight * 0.06,
                        color: Colors.white,
                      ),

                      //FOLLOWING
                      FlatButton(
                        onPressed: () {},
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        splashColor: Colors.white30,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'FOLLOWING',
                              style: textStyle2,
                            ),
                            Text(
                              details.following.toString(),
                              style: textStyle2,
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          //USER DP
          Container(
            margin: EdgeInsets.only(top: 10),
            alignment: FractionalOffset.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                  height: pageHeight * 0.1,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.network(
                    details.photoUrl,
                    height: pageHeight * 0.1,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, event) {
                      if (event == null) {
                        return child;
                      }
                      var val = event.cumulativeBytesLoaded /
                          event.expectedTotalBytes;
                      if (val == 1) {
                        return child;
                      } else if (val < 1) {
                        //Using Center to make sure the ProgressIndicator is
                        //in the center of the stack
                        return Center(
                            //Using SizedBox to maintain the size of the ProgressIndicator
                            child: SizedBox(
                          height: pageHeight * 0.05,
                          width: pageHeight * 0.05,
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
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
