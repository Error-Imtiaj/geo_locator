import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _googleMapController;
  LatLng _currentPosition = const LatLng(0, 0);
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> _routeCoordinates = [];
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(22.34433835192831, 91.78941230711727),
    zoom: 17,
  );
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchLocation();
  }
  Future<void> _checkPermissionsAndFetchLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _fetchCurrentLocation();
      _startLocationUpdates();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _routeCoordinates.add(_currentPosition);
        _addMarker(_currentPosition);
        _animateCamera(_currentPosition);
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _routeCoordinates.add(newPosition);
        _addPolyline();
        _addMarker(newPosition);
        _animateCamera(newPosition);
        _currentPosition = newPosition;
      });
    });
  }

  void _animateCamera(LatLng position) {
    _googleMapController.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _addMarker(LatLng position) {
    _markers = {
      Marker(
        markerId: const MarkerId("current_location"),
        position: position,
        infoWindow: InfoWindow(
          title: "My Current Location",
          snippet: "${position.latitude}, ${position.longitude}",
        ),
      )
    };
  }

  void _addPolyline() {
    _polylines = {
      Polyline(
        polylineId: const PolylineId("route"),
        points: _routeCoordinates,
        color: Colors.blue,
        width: 4,
      )
    };
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text(
            "Location permission is required to use this feature. Please enable it in settings."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await Geolocator.openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map Example"),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        mapType: MapType.satellite,
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // Disabling the default GPS button
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _animateCamera(_currentPosition);
        },
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
}
