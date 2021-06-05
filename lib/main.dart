import 'package:flutter/material.dart';
import 'package:my_fav_locations/mapView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Application root widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Tittle of the application
      title: 'My favourite locations',

      // Set the main colors to be used by the app
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),

      // Main screen page
      home: MyMapView(),
    );
  }
}

