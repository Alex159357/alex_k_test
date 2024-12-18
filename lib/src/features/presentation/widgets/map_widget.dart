import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/presentation/providers/custom_tile_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../../../config/api_keys.dart';

class MapWidget extends StatefulWidget {
  final double userLat;
  final double userLng;
  final List<MapPinEntity> pins;
  final Function(double lat, double lng) onMapTap;
  final Function(double? id)? onPinTap;
  final double initialZoom;

  const MapWidget({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.pins,
    required this.onMapTap,
    this.onPinTap, // Optional callback
    this.initialZoom = 13.0, // Increased default zoom
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController mapController = MapController();
  bool _isDownloading = false;
  bool _isInitialized = false;
  late Directory _cacheDir;
  TileProvider? _tileProvider;

  // Define map bounds for San Francisco area
  static final LatLng _swBound = LatLng(37.6, -122.6);
  static final LatLng _neBound = LatLng(37.9, -122.2);

  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/map_tiles');
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }
      _tileProvider = CustomTileProvider(_cacheDir.path);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing cache: $e');
    }
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat >= _swBound.latitude &&
        lat <= _neBound.latitude &&
        lng >= _swBound.longitude &&
        lng <= _neBound.longitude;
  }

  Future<void> _downloadRegion() async {
    if (_isDownloading || !_isInitialized) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final bounds = mapController.bounds!;
      final zoom = mapController.zoom.floor();

      final sw = bounds.southWest;
      final ne = bounds.northEast;

      final minX = _lon2tile(sw.longitude, zoom);
      final maxX = _lon2tile(ne.longitude, zoom);
      final minY = _lat2tile(ne.latitude, zoom);
      final maxY = _lat2tile(sw.latitude, zoom);

      for (var x = minX; x <= maxX; x++) {
        for (var y = minY; y <= maxY; y++) {
          if (!mounted) return;

          final url =
              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$zoom/$x/$y?access_token=${ApiKeys.mapboxAccessToken}';
          final file = File('${_cacheDir.path}/${zoom}_${x}_${y}.png');

          try {
            if (!await file.exists()) {
              final request = await HttpClient().getUrl(Uri.parse(url));
              final response = await request.close();
              if (response.statusCode == 200) {
                await response.pipe(file.openWrite());
              }
            }
          } catch (e) {
            debugPrint('Error downloading tile $zoom/$x/$y: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error downloading region: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  int _lon2tile(double lon, int z) {
    return ((lon + 180.0) / 360.0 * (1 << z)).floor();
  }

  int _lat2tile(double lat, int z) {
    final latRad = lat * pi / 180.0;
    return ((1.0 - log((1 + sin(latRad)) / (1 - sin(latRad))) / (2 * pi)) /
            2.0 *
            (1 << z))
        .floor();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Add user location marker
    if (_isValidCoordinate(widget.userLat, widget.userLng)) {
      markers.add(
        Marker(
          point: LatLng(widget.userLat, widget.userLng),
          width: 80,
          height: 80,
          child: Column(
            children: [
              Icon(
                Icons.person_pin_circle,
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  'You',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add custom pins
    for (final pin in widget.pins) {
      if (_isValidCoordinate(pin.latitude, pin.longitude)) {
        markers.add(
          Marker(
            point: LatLng(pin.latitude, pin.longitude),
            width: 100,
            height: 100,
            child: GestureDetector(
              // Added GestureDetector for tap handling
              onTap: () {
                if (widget.onPinTap != null) {
                  widget.onPinTap!(pin.id);
                }
              },
              child: Column(
                children: [
                  Icon(
                    Icons.location_pin,
                    color: Theme.of(context).primaryColor,
                    size: 60,
                  ),
                  if (pin.label.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        pin.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      } else {
        print("Skipping invalid pin -> $pin");
      }
    }

    return markers;
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (_isValidCoordinate(point.latitude, point.longitude)) {
      widget.onMapTap(point.latitude, point.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.userLat, widget.userLng),
              initialZoom: widget.initialZoom,
              minZoom: 11.0, // Increased minimum zoom
              maxZoom: 18.0,
              keepAlive: true,
              onTap: _handleTap,
              interactionOptions: const InteractionOptions(
                enableScrollWheel: true,
                enableMultiFingerGestureRace: true,
              ),
              // Add bounds
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(_swBound, _neBound),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: const {
                  'accessToken': ApiKeys.mapboxAccessToken,
                },
                tileProvider: _tileProvider!,
                keepBuffer: 50,
                backgroundColor: Colors.grey[300],
                maxZoom: 18,
                minZoom: 11,
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _isDownloading ? null : _downloadRegion,
              child: _isDownloading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.download),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
