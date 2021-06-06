import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// Base BLoC class
class BlocBase {}

// Input events to the BLoC
class SavePlace extends BlocBase {
  final String name;
  final double lat;
  final double lon;

  SavePlace(this.name, this.lat, this.lon);
}

class GetPlaces extends BlocBase{}
class GetTemp extends BlocBase{}
class ClearMarkers extends BlocBase{}

class PlacesBloc {
  // Create a CollectionReference called places that references the firestore collection
  CollectionReference places = FirebaseFirestore.instance.collection('places');

  // BLoC input and output Listeners
  StreamController<BlocBase> _input = StreamController();
  StreamController<Set<Marker>> _output = StreamController();
  StreamController<String> _output2 = StreamController();

  // Result stream from processing the event
  Stream<Set<Marker>> get saveStream => _output.stream;
  Stream<String>      get tempStream => _output2.stream;

  // Listen to new events coming from the UI
  StreamSink<BlocBase> get sendEvent => _input.sink;

  // Create markers list to allocate all saved places
  Set<Marker> markers = Set();

  // Event processing
  PlacesBloc(){
    _input.stream.listen(_onEvent);
  }

  // Avoid memory leaks removing unused resources
  void dispose(){
    _input.close();
    _output.close();
    _output2.close();
  }

  // Private method to prevent manually callings from outside
  Future<void> _onEvent(BlocBase event) async {
    // Check which event has been received from the UI
    if (event is SavePlace){
      // Firebase saving process
      await addPlace(event.name, event.lon, event.lat);
    }else if (event is GetPlaces){
      // Get all saved places from Firebase
      await getPlaces();
    }else if (event is GetTemp){
      await getTemperature();
    }else{
      // Avoid showing any marker while in the save tab
      markers.clear();
      _output.add(markers);
    }
  }

  // Add a new saved place to Firebase as new document of the collection 'Places'
  Future<void> addPlace(String name, double longitude, double latitude) {
    // Call the places CollectionReference to add a new place
    return places
        .add({
      'name': name,
      'latlon': GeoPoint(latitude, longitude),
    });
  }

  // Get all documents from Firebase under 'Places' collection
  Future<void> getPlaces() async {
    // Used to decode Geo location point coming from my saved place
    GeoPoint locationPoint;

    // Get all documents under 'places' collection, each document is a place saved
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('places').get();

    // Parse the snapshot into a Map
    Map<int, QueryDocumentSnapshot<Object>> myPlacesList = snapshot.docs.asMap();

    // Marker of the saved place
    Marker marker;

    // Clear markers list before adding places coming from Firebase
    markers.clear();

    // Loop through all places
    for(var place in myPlacesList.values) {
      locationPoint = place.get('latlon');

      // Create a new marker with the info received from FireBase
      marker = Marker(
          infoWindow: InfoWindow(title: place.get('name'), snippet: locationPoint.latitude.abs().toString()+" "+locationPoint.longitude.abs().toString()),
          markerId: MarkerId(place.get('name')),
          position: LatLng(locationPoint.latitude, locationPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueCyan),
      );

      // Add the saved place into the markers list
      markers.add(marker);
    }

    // Add the newer info to the stream to let the UI update its content
    _output.add(markers);
  }

  // Get current location temperature using open weather
  Future<void> getTemperature() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    String tempQuery = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=db01a058045155a6002827531e3dee91&units=metric';
    http.Response responseGetParams = await http.get(Uri.parse(tempQuery),headers: {"Accept": "application/json"});

    var data = jsonDecode(responseGetParams.body);
    print(data);
    print(data['main']['temp']);

    // Add the newer info to the stream to let the UI update its content
    _output2.add(data['main']['temp'].toString());
  }
}

