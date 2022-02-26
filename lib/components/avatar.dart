import 'package:flutter/material.dart';
import 'package:hapi/components/logo_graphic_header.dart';
import 'package:hapi/onboard/user_model.dart';

// TODO unused we can use again to show gravatar
/// displays a user avatar on the X.
class Avatar extends StatelessWidget {
  const Avatar(
    this.user,
  );
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl == '') {
      return LogoGraphicHeader();
    }
    return Hero(
      tag: 'User Avatar Image',
      child: CircleAvatar(
          foregroundColor: Colors.blue,
          backgroundColor: Colors.white,
          radius: 70.0,
          child: ClipOval(
            child: Image.network(
              user.photoUrl,
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
            ),
          )),
    );
  }
}
