import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CrowdStatusScreen extends StatefulWidget {
  const CrowdStatusScreen({super.key});

  @override
  State<CrowdStatusScreen> createState() => _CrowdStatusScreenState();
}

class _CrowdStatusScreenState extends State<CrowdStatusScreen> {
  late GoogleMapController _mapController;
  int _visitorCount = 0;
  // Instead of heatmaps, we use markers.
  final Set<Marker> _markers = {};
  final LatLng _museumCenter = const LatLng(25.2048, 55.2708); // UAE coordinates

  // Mock crowd data (replace with real API data)
  final List<LatLng> _crowdDensity = [
    const LatLng(25.2049, 55.2709), // High traffic
    const LatLng(25.2047, 55.2707), // Medium traffic
    const LatLng(25.2050, 55.2710), // Low traffic
  ];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _startVisitorCounter();
  }

  void _initializeMarkers() {
    // For each point, generate a random intensity to simulate crowd density
    for (final point in _crowdDensity) {
      double intensity = _getRandomIntensity();
      Color markerColor;
      // Decide marker color based on intensity thresholds
      if (intensity > 0.66) {
        markerColor = Colors.red;
      } else if (intensity > 0.33) {
        markerColor = Colors.yellow;
      } else {
        markerColor = Colors.green;
      }
      final marker = Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(title: 'Crowd: ${(intensity * 100).toStringAsFixed(0)}%'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _colorToHue(markerColor),
        ),
      );
      _markers.add(marker);
    }
  }

  // Convert a Color to a hue value for the default marker icon
  double _colorToHue(Color color) {
    HSVColor hsv = HSVColor.fromColor(color);
    return hsv.hue;
  }

  void _startVisitorCounter() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _visitorCount = _getRandomCount(150, 300);
      });
    });
  }

  int _getRandomCount(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  double _getRandomIntensity() {
    return Random().nextDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crowd Status'),
        actions: [
          Chip(
            label: Text('Visitors: $_visitorCount'),
            backgroundColor: Colors.blue[100],
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _museumCenter,
              zoom: 18,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
          ),
          _buildLegend(),
          _buildSuggestRouteButton(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 10,
      left: 10,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Low Crowd', Colors.green),
              _buildLegendItem('Moderate Crowd', Colors.yellow),
              _buildLegendItem('High Crowd', Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildSuggestRouteButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.extended(
        icon: const Icon(Icons.alt_route),
        label: const Text('Suggest Quiet Route'),
        backgroundColor: Colors.green,
        onPressed: _suggestOptimalRoute,
      ),
    );
  }

  void _suggestOptimalRoute() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suggested Route'),
        content: const Text('New route avoids crowded areas'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}