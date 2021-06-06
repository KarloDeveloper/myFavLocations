import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng _currentPosition;

  // Variable to define GoogleMaps map type
  MapType _currentMapType = MapType.normal;

  // Create a GoogleMaps Completer variable and a camera controller
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapControllerCamera;

  // Bottom naviagtion bar selected index
  int _currentIndex = 0;

  // Places BLoC instance
  PlacesBloc _bloc = PlacesBloc();

  // Create a controller of the place name textfield
  TextEditingController _nameController = TextEditingController();

  // Define constants for random id generation for unnamed saved places
  String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  // Set _controller as completed when maps finishes loading
  void _onMapCreated(GoogleMapController controller) async{
    if(_controller.isCompleted != true){
      _controller.complete(controller);
    }
  }

  // Get center coordinates on map movement
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  // Random ID calculation function to unnamed saved places
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

  @override
  void initState() {
    getUserLocation();

    // Trigger the get locations event at the start of the app to get any place saved
    _bloc.sendEvent.add(GetPlaces());
    super.initState();
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
          _currentPosition == null?
          Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan)),
          ):
          StreamBuilder<Set<Marker>>(
            stream: _bloc.saveStream,
            builder: (context, snapshot){
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan)));
              }else{
                return GoogleMap(
                  onCameraMove: _onCameraMove,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: true,
                  mapType: _currentMapType,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  markers: snapshot.data,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15.0,
                  ),
                );
              }
            },
          ),

          temperatureWidget(),

          _currentIndex == 0? Container() : saveWidget(),

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
          padding: EdgeInsets.fromLTRB(10.0, 70.0, 10.0, 0.0),
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
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(8),
              child:  FloatingActionButton(
                onPressed: () {
                  // Avoid storing a place with an empty name
                  if(_nameController.text.length == 0){
                    _nameController.text =
                        AppLocalizations.of(context).translate('no_name')
                            +": "+getRandomString(5);
                  }

                  // Trigger the storage location event
                  _bloc.sendEvent.add(SavePlace(_nameController.text, _lastMapPosition.latitude, _lastMapPosition.longitude));

                  // Clear the text field once a new place has been saved
                  _nameController.clear();
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
      padding: EdgeInsets.only(top: 10, left: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: Colors.transparent,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: StreamBuilder<String>(
            stream: _bloc.tempStream,
            builder: (context, snapshot){
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child:  Text(AppLocalizations.of(context).translate('loc_temp'),
                    style: new TextStyle(
                        fontFamily: 'MontserratRegular',
                        color: Colors.black54,
                        fontSize: 18
                    ),
                  ),
                );
              }else{
                return Padding(
                  padding: EdgeInsets.all(8),
                  child:  Text("${snapshot.data} ºC",
                    style: new TextStyle(
                        fontFamily: 'MontserratRegular',
                        color: Colors.black54,
                        fontSize: 24
                    ),
                  ),
                );
              }
            },
          ),
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

          if (_currentIndex == 0){
            // Trigger the get locations event
            _bloc.sendEvent.add(GetPlaces());
          }else{
            // Clear Markers list when in Save Places screen
            _bloc.sendEvent.add(ClearMarkers());
          }
        },
        selectedItemColor: Colors.cyan,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Function used to get actual device location using the GPS
  void getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _lastMapPosition = _currentPosition;
    });

    // Trigger the get temperature event to show current location temperature
    _bloc.sendEvent.add(GetTemp());
  }
}