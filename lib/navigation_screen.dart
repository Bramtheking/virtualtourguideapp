import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:camera/camera.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  final String _mapImage = 'assets/museum_map.jpg';
  Offset? _currentPosition;
  Offset? _selectedExhibit;
  List<Offset> _pathPoints = [];
  bool _arMode = false;
  bool _accessibleRoute = false;
  double _scale = 1.0;

  // Define locations and their names.
  final Map<String, Offset> _exhibits = {
    'Islamic Art': const Offset(0.25, 0.35),
    'Space Exhibit': const Offset(0.72, 0.55),
    'History Hall': const Offset(0.45, 0.78),
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Navigation'),
        actions: [
          IconButton(
            icon: Icon(_arMode ? Icons.map : Icons.camera_alt),
            onPressed: () => setState(() => _arMode = !_arMode),
          ),
        ],
      ),
      body: _buildMainContent(),
      floatingActionButton: _buildRouteOptions(),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        _arMode ? _buildARCameraView() : _buildInteractiveMap(),
        CustomPaint(painter: PathPainter(points: _pathPoints)),
        ..._exhibits.entries.map((e) => _buildExhibitMarker(e.key, e.value)),
      ],
    );
  }

  Widget _buildInteractiveMap() {
    return GestureDetector(
      onScaleUpdate: (details) => setState(() => _scale = details.scale),
      child: PhotoView(
        imageProvider: AssetImage(_mapImage),
        minScale: PhotoViewComputedScale.contained,
        maxScale: 5.0,
      ),
    );
  }

  Widget _buildARCameraView() {
    return _isCameraInitialized
        ? CameraPreview(_cameraController)
        : const Center(child: CircularProgressIndicator());
  }

  // Updated marker widget: always show the location name above the marker icon.
  Widget _buildExhibitMarker(String name, Offset position) {
    return Positioned(
      left: position.dx * MediaQuery.of(context).size.width,
      top: position.dy * MediaQuery.of(context).size.height,
      child: GestureDetector(
        onTap: () => _handleExhibitSelection(name, position),
        child: Column(
          children: [
            // Display the marker name always on top.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white,
              child: Text(
                name,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            Icon(
              Icons.location_pin,
              color: (_selectedExhibit == position) ? Colors.red : Colors.blue,
              size: 40 * _scale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: _calculateRoute,
          child: const Icon(Icons.directions),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () => setState(() => _accessibleRoute = !_accessibleRoute),
          backgroundColor: _accessibleRoute ? Colors.green : null,
          child: const Icon(Icons.accessible),
        ),
      ],
    );
  }

  void _handleExhibitSelection(String name, Offset position) {
    setState(() {
      _selectedExhibit = position;
      _currentPosition ??= const Offset(0.5, 0.9);
    });
    _calculateRoute();
  }

  void _calculateRoute() {
    if (_currentPosition == null || _selectedExhibit == null) return;
    setState(() {
      _pathPoints = [_currentPosition!, _selectedExhibit!];
    });

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildRouteDetailsSheet(context),
    );
  }

  Widget _buildRouteDetailsSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Route Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Destination: ${_exhibits.entries.firstWhere((e) => e.value == _selectedExhibit).key}"),
        ],
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> points;
  PathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    if (points.length > 1) {
      final path = Path()
        ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
      for (var point in points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
