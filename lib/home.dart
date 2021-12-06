import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool _isActive = false;
  double latitude = 0.0;
  double longitude = 0.0;

  late StreamSubscription positionStream;

  final errorSnackBar = const SnackBar(
      content: Text('Location services are disabled.')
  );

  final deniedSnackBar = const SnackBar(
      content: Text('Location permissions are denied.')
  );

  final permanentlyDeniedSnackBar = const SnackBar(
      content: Text('Location permissions are permanently denied, we cannot request permissions.')
  );

  final acceptedSnackBar = const SnackBar(
      content: Text('Location permissions are accepted.')
  );

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Flutter Geolocator'),
      ),
      body: Center(
        child: _isActive
            ? locationText()
            : ElevatedButton(
                onPressed: () => _onButtonClick(),
                child: const Text('Press Me to Activate Geolocation'),
              ),
      ),
    );
  }

  Future<void> _onButtonClick() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(deniedSnackBar);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(permanentlyDeniedSnackBar);
    }

    setState(() {
      _isActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(acceptedSnackBar);
    positionStream = Geolocator.getPositionStream().listen((event) {
      setState(() {
        latitude = event.latitude;
        longitude = event.longitude;
        debugPrint('The device location changed');
      });
    });
  }

  Widget locationText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Your Location:'),
        const SizedBox(height: 5.0,),
        Text('Lat: $latitude'),
        const SizedBox(height: 2.0,),
        Text('Lng: $longitude'),
      ],
    );
  }

}
