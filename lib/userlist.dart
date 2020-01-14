import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_flutter/userinformation.dart';

class UserListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserListPageState();
  }
}

class UserListPageState extends State<UserListPage> {
  var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');
  List<UserDisplayDetails> userlist = List();

  UserListPageState() {
    wallpaperdb.onChildAdded.listen(dbadd);
  }

  @override
  Widget build(BuildContext context) {
    final double hsize = MediaQuery.of(context).size.height;
    final double wsize = MediaQuery.of(context).size.width;
    return Dialog(
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(width: 5, color: Color(0xFF1b1b1b))),
        backgroundColor: Color(0xFF484848),
        child: Container(
            // width: wsize,
            height: hsize * 0.5,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Text(
                    'USERS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Container(
                      // width: wsize,
                      height: (hsize * 0.5) - 40,
                      child: ListView(
                          children: userlist
                              .map((element) => Card(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          element.dpUrl,
                                          height: 35,
                                        ),
                                      ),
                                      Text(
                                        element.userName,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          FontAwesomeIcons.plus,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    ],
                                  )))
                              .toList()),
                    )),
              ],
            )));
  }

  dbadd(Event event) {
    //For userlist
    var user = new UserDisplayDetails.fromJSON(event.snapshot.value);
    userlist.add(user);
    setState(() {});
  }
}
