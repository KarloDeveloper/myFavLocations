import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_fav_locations/blocs/placesBloc.dart';
import 'appLocalizations.dart';

class MyMapView extends StatefulWidget {
  @override
  _MyMapView createState() => _MyMapView();
}

class _MyMapView extends State<MyMapView> {
  // Variables used to get map coordinates
  static const LatLng _center = const LatLng(41.1, 1.21);
  LatLng _lastMapPosition = _center;

  // Variable to define GoogleMaps map type
  MapType _currentMapType = MapType.normal;

  // Create a GoogleMaps Completer variable
  Completer<GoogleMapController> _controller = Completer();

  // Bottom naviagtion bar selected index
  int _currentIndex = 0;

  // Places BLoC instance
  PlacesBloc _bloc = PlacesBloc();

  TextEditingController _nameController = TextEditingController();

  // Set _controller as completed when maps finishes loading
  void _onMapCreated(GoogleMapController controller) async{
    if(_controller.isCompleted != true){
      _controller.complete(controller);
    }
  }

  // Get center coordinates on map movement
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    print("Pos" +_lastMapPosition.toString());
  }

  // Avoid memory leaks removing unused resources
  @override
  void dispose() {
    _bloc.dispose();
    _nameController.dispose();
    super.dispose();
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
            onCameraMove: _onCameraMove,
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

          _currentIndex == 0?
          temperatureWidget():
          saveWidget(),

          Center(
            child: Icon(
              Icons.close,
              color: _currentIndex == 1? Colors.black:Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  // Floating button and name input text widgets used to save a new location
  Widget saveWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(40.0, 15.0, 40.0, 0.0),
          child: new TextFormField(
            controller: _nameController,
            decoration: new InputDecoration(
              labelText: AppLocalizations.of(context).translate('loc_name'),
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(
                ),
              ),
              //fillColor: Colors.green
            ),
            style: new TextStyle(
              fontFamily: "MontserratRegular",
            ),
          ),
        ),

        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child:
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(8),
                child:  FloatingActionButton(
                  onPressed: () {
                    // Trigger the storage location event
                    _bloc.sendEvent.add(SavePlace(_nameController.text, _lastMapPosition.latitude, _lastMapPosition.longitude));
                  },
                  child: Icon(
                    Icons.save,
                    color: Colors.black54,
                  ),
                  backgroundColor: Colors.cyan,
                ),
              ),
            )
        ),
      ],
    );
  }

  // Temperature of the current location widget
  Widget temperatureWidget(){
    return Padding(
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
              ),
            ),
          )
        ),
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