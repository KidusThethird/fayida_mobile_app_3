import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Add your logic for Item 1 here
              Navigator.of(context).pop(); // Close the drawer
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Add your logic for Item 2 here
              Navigator.of(context).pop(); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
