import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _googleMapController;
  final LatLng _initialPosition =
      const LatLng(22.34433835192831, 91.78941230711727);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google map"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          zoom: 17,
          target: _initialPosition,
        ),
        mapType: MapType.satellite,
        compassEnabled: true,
        mapToolbarEnabled: true,
        //minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        trafficEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _googleMapController = controller;
        },
        polylines:  Set(Polyline(polylineId: PolylineId("route"))),
      ),
    );
  }
}
