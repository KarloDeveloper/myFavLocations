import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_fav_locations/mapView.dart';
import 'appLocalizations.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Application root widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove debug banner
      debugShowCheckedModeBanner: false,

      // Tittle of the application
      title: 'My favourite locations',

      // Set the main colors to be used by the app
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),

      // Set English and Spanish as supported languages
      supportedLocales: [
        Locale('en', ''),
        Locale('es', ''),
      ],

      localizationsDelegates: [
        // A class which loads the translations from JSON files
        AppLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate
      ],

      // Return the locale to be used by app if supported
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }

        /* If the locale of the device is not supported by the app, use the
         * first one from the list as default language (English in this case).
         */
        return supportedLocales.first;
      },

      // Main screen page
      home: MyMapView(),
    );
  }
}

