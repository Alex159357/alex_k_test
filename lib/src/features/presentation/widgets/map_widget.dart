import 'dart:io';
import 'dart:math';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/presentation/providers/custom_tile_provider.dart';
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
  final Function(int? id)? onPinTap;
  final double initialZoom;

  const MapWidget({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.pins,
    required this.onMapTap,
    this.onPinTap,
    this.initialZoom = 13.0,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  bool _isDownloading = false;
  bool _isInitialized = false;
  late Directory _cacheDir;
  TileProvider? _tileProvider;
  TabController? _tabController;
  List<Marker> _markers = [];
  Color? _primaryColor;

  @override
  void initState() {
    super.initState();
    _initializeCache();
    _initTabController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPrimaryColor = Theme.of(context).primaryColor;
    if (_primaryColor != newPrimaryColor) {
      _primaryColor = newPrimaryColor;
      _buildMarkers();
    }
  }

  void _initTabController() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    if (widget.pins.isNotEmpty) {
      _tabController = TabController(length: widget.pins.length, vsync: this);
      _tabController!.addListener(_handleTabChange);
    } else {
      _tabController = null;
    }
  }

  void _handleTabChange() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      final selectedPin = widget.pins[_tabController!.index];
      mapController.move(
        LatLng(selectedPin.latitude, selectedPin.longitude),
        mapController.camera.zoom,
      );
    }
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLat != widget.userLat ||
        oldWidget.userLng != widget.userLng ||
        oldWidget.pins != widget.pins) {
      _buildMarkers();
    }
    if (oldWidget.userLat != widget.userLat ||
        oldWidget.userLng != widget.userLng) {
      mapController.move(
          LatLng(widget.userLat, widget.userLng), mapController.camera.zoom);
    }
    if (oldWidget.pins.length != widget.pins.length) {
      _initTabController();
    }
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
          final file = File('${_cacheDir.path}/${zoom}_${x}_$y.png');

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

  void _buildMarkers() {
    if (!mounted || _primaryColor == null) return;

    final markers = <Marker>[];

    // Add user location marker
    markers.add(
      Marker(
        point: LatLng(widget.userLat, widget.userLng),
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(
              Icons.person_pin_circle,
              color: _primaryColor,
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

    // Add custom pins
    for (final pin in widget.pins) {
      markers.add(
        Marker(
          point: LatLng(pin.latitude, pin.longitude),
          width: 100,
          height: 100,
          child: GestureDetector(
            onTap: () {
              if (widget.onPinTap != null) {
                widget.onPinTap!(pin.id);
              }
            },
            child: Column(
              children: [
                Badge(
                  isLabelVisible: pin.firebaseId == null,
                  smallSize: 6,
                  largeSize: 16,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  label: const Icon(
                    Icons.sync_disabled,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.location_pin,
                    color: _primaryColor,
                    size: 60,
                  ),
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
    }

    setState(() {
      _markers = markers;
    });
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    widget.onMapTap(point.latitude, point.longitude);
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: 80,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "centerLocation",
            onPressed: () {
              mapController.move(
                LatLng(widget.userLat, widget.userLng),
                mapController.camera.zoom,
              );
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoomIn",
            onPressed: () {
              mapController.move(
                mapController.camera.center,
                mapController.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoomOut",
            onPressed: () {
              mapController.move(
                mapController.camera.center,
                mapController.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _buildTabBar() {
    if (widget.pins.isEmpty || _tabController == null) {
      return null;
    }
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: widget.pins.map((pin) {
        return Tab(
          child: Row(
            children: [
              const Icon(Icons.location_pin),
              const SizedBox(width: 8),
              Text(pin.label.isEmpty ? 'Pin ${pin.id}' : pin.label),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          bottom: _buildTabBar(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.userLat, widget.userLng),
              initialZoom: widget.initialZoom,
              minZoom: 2.0,
              maxZoom: 18.0,
              onTap: _handleTap,
              interactionOptions: const InteractionOptions(
                enableScrollWheel: true,
                enableMultiFingerGestureRace: true,
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
                backgroundColor: Colors.grey[300],
                maxZoom: 18,
                minZoom: 2,
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          _buildMapControls(),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "download",
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
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }
}
