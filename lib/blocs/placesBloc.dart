import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Base BLoC class
class BlocBase {}

// Input events to the BLoC
class SavePlace extends BlocBase {
  final String name;
  final double lat;
  final double lon;

  SavePlace(this.name, this.lat, this.lon);
}

class PlacesBloc {
  // Create a CollectionReference called places that references the firestore collection
  CollectionReference places = FirebaseFirestore.instance.collection('places');

  // Listeners
  StreamController<BlocBase> _input = StreamController();
  StreamController<int> _output = StreamController();

  // Result stream from processing the event
  Stream<int> get saveStream => _output.stream;

  // Listen to new events coming from the UI
  StreamSink<BlocBase> get sendEvent => _input.sink;

  // Event processing
  PlacesBloc(){
    _input.stream.listen(_onEvent);
  }

  // Avoid memory leaks removing unused resources
  void dispose(){
    _input.close();
    _output.close();
  }

  // Private method to prevent manually callings from outside
  Future<void> _onEvent(BlocBase event) async {
    // Check which event has been received from the UI
    if (event is SavePlace){
      // Firebase saving process
      await addPlace(event.name, event.lon, event.lat);

      // Get all saved places from Firebase
      //getPlaces();
    }

    // Add the newer info to the stream to let the UI update its content
    _output.add(0);
  }

  Future<void> addPlace(String name, double longitude, double latitude) {
    // Call the places CollectionReference to add a new place
    return places
        .add({
      'name': name,
      'latlon': GeoPoint(latitude, longitude),
    });
  }

  /*Future<void> getPlaces() {
    // Call the user's CollectionReference to add a new user
    return places
        .add({
      'name': "Barcelona", // John Doe
      'latlon': "41.1, 1.31", // Stokes and Sons
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }*/
}

