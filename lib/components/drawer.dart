import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/list_tile.dart';
import 'package:flutter_application_1/pages/home_page.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onLogoutTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          // header
          const DrawerHeader(
            child: Icon(Icons.person, color: Colors.white, size: 64),
          ),

          // home list tile
          MyListTile(
            icon: Icons.home,
            text: "Home",
            onTap: () => Navigator.pop(context),
          ),

          // profile list tile
          MyListTile(icon: Icons.person, text: "Profile", onTap: onProfileTap),

          // logout list tile
          MyListTile(icon: Icons.logout, text: "Logout", onTap: onLogoutTap),
        ],
      ),
    );
  }
}
