import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'appLocalizations.dart';

class MyMapView extends StatefulWidget {
  @override
  _MyMapView createState() => _MyMapView();
}

class _MyMapView extends State<MyMapView> {

  // Variable to define GoogleMaps map type
  MapType _currentMapType = MapType.normal;

  // Create a GoogleMaps Completer variable
  Completer<GoogleMapController> _controller = Completer();

  // Bottom naviagtion bar selected index
  int _currentIndex = 0;

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
          title: Text(
            AppLocalizations.of(context).translate('app_title'),
            style: new TextStyle(
              fontFamily: 'MontserratBold',
              color: Colors.black54,
            ),
          ),
        ),
        body: googleMapsWidget(),
        bottomNavigationBar: bottomNavBar(),
    );
  }

  // GoogleMaps with current location temperature widget
  Widget googleMapsWidget() {
    return Container(
      child: Stack(
        children: [
          // Google maps
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

          // Temperature of the current location
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: 
                Padding(
                  padding: EdgeInsets.all(8),
                  child:  Text("21 ºC",
                    style: new TextStyle(
                      fontFamily: 'MontserratRegular',
                      color: Colors.white,
                      fontSize: 18
                    ),),
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  // Bottom navigation bar used to navigate to the 'Map' or 'Places' screens
  Widget bottomNavBar(){
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 5.0,
            )
          ]
      ),

      child:  BottomNavigationBar(
        elevation: 10.0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: AppLocalizations.of(context).translate('map_text'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            label: AppLocalizations.of(context).translate('places_text'),
          ),
        ],
        selectedLabelStyle: TextStyle(
          fontFamily: 'MontserratBold',
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'MontserratRegular',
          fontSize: 14,
        ),
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.cyan,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}