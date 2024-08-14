import 'package:flutter/material.dart';

import '../models/packagelist.dart';
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
                print(PackageListServices().getAllPackages());
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
          future: PackageListServices().getAllPackages(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error fetching package data"),
              );
            }
            if (snapshot.hasData) {
              var data = snapshot.data as List<Package>;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data[index].imgUrl![0]),
                    ),
                    title: Text("${data[index].packageName}"),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
