import 'package:flutter/material.dart';

import '../services/packageList_services.dart';

class PackagesListScreen extends StatelessWidget {
  const PackagesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Packages List"),
        actions: [
          IconButton(
              onPressed: () {
                PackageListServices().getAllPackages();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
    );
  }
}
