import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMapView extends StatefulWidget {
  @override
  _MyMapView createState() => _MyMapView();
}

class _MyMapView extends State<MyMapView> {

  // Variable to define GoogleMaps map type
  MapType _currentMapType = MapType.normal;

  // Create a GoogleMaps Completer variable
  Completer<GoogleMapController> _controller = Completer();

  // Set _controller as completed when maps finishes loading
  void _onMapCreated(GoogleMapController controller) async{
    if(_controller.isCompleted != true){
      _controller.complete(controller);
    }
  }

  // Main Widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Favourite Locations"),
        ),
        body: googleMapsWidget(),
    );
  }

  // GoogleMaps widget
  Widget googleMapsWidget() {
    return Container(
      child: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapToolbarEnabled: true,
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(41.1, 1.24),
              zoom: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}