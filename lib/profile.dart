import 'package:flutter/material.dart';
import 'package:hello_flutter/userinformation.dart';

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
  ProfilePageState(this.details);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[],
    );
  }
}
