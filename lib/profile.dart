import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/wallpaper.dart';

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
  }

  dbadd(Event event) {
    UserDisplayDetails user = UserDisplayDetails(
        details.photoUrl, details.userEmail, details.userName);
    var wallp = new Wallpaper.fromJSON(event.snapshot.value, user);
    profileWallpaperList.add(wallp);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height;
    final double wsize = MediaQuery.of(context).size.width;
    double pageSize = (hsize-kToolbarHeight-kBottomNavigationBarHeight-24);
    double cardHeight = (pageSize*0.3)+45+10;
    return Column(
      children: <Widget>[
        ProfileDetailsCard(details),
        Container(
          height: pageSize-cardHeight,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            children: profileWallpaperList.map((element) {
              return Card(
                child: Column(
                  children: <Widget>[Image.network(element.imglink)],
                ),
              );
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
  ProfileDetailsCardState(this.details);
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
            margin: EdgeInsets.fromLTRB(10, 45, 10, 10),
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
                      )
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
              child: Image.network(
                details.photoUrl,
                height: pageHeight * 0.1,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
