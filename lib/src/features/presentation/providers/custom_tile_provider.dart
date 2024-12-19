

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CustomTileProvider extends TileProvider {
  final String basePath;
  final HttpClient _httpClient = HttpClient();
  final Map<String, bool> _downloadingTiles = {};

  CustomTileProvider(this.basePath);

  @override
  bool get supportsCancelLoading => true;

  String _getTileKey(TileCoordinates coordinates) {
    return '${coordinates.z}_${coordinates.x}_${coordinates.y}';
  }

  File _getTileFile(TileCoordinates coordinates) {
    return File('$basePath/${_getTileKey(coordinates)}.png');
  }

  @override
  ImageProvider getImageWithCancelLoadingSupport(
      TileCoordinates coordinates,
      TileLayer options,
      Future<void> cancelLoading,
      ) {
    final file = _getTileFile(coordinates);
    final tileKey = _getTileKey(coordinates);

    if (file.existsSync()) {
      return FileImage(file);
    }

    if (_downloadingTiles[tileKey] == true) {
      return MemoryImage(Uint8List(0));
    }

    final url = options.urlTemplate!
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString())
        .replaceAll(
        '{accessToken}', options.additionalOptions['accessToken'] ?? '');

    _downloadingTiles[tileKey] = true;

    // Start downloading the tile
    _downloadTile(url, file, tileKey).then((_) {
      _downloadingTiles.remove(tileKey);
    }).catchError((e) {
      debugPrint('Error downloading tile $tileKey: $e');
      _downloadingTiles.remove(tileKey);
    });

    return NetworkImage(url);
  }

  Future<void> _downloadTile(String url, File file, String tileKey) async {
    try {
      if (!await file.exists()) {
        final request = await _httpClient.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          await file.writeAsBytes(bytes);
        }
      }
    } catch (e) {
      debugPrint('Error downloading tile $tileKey: $e');
      rethrow;
    }
  }

  @override
  Future<Uint8List> getTileBytes(
      TileCoordinates coordinates, TileLayer options) async {
    final file = _getTileFile(coordinates);
    final tileKey = _getTileKey(coordinates);

    try {
      if (await file.exists()) {
        return await file.readAsBytes();
      }

      final url = options.urlTemplate!
          .replaceAll('{z}', coordinates.z.toString())
          .replaceAll('{x}', coordinates.x.toString())
          .replaceAll('{y}', coordinates.y.toString())
          .replaceAll(
          '{accessToken}', options.additionalOptions['accessToken'] ?? '');

      final request = await _httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed to download tile: ${response.statusCode}');
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return bytes;
    } catch (e) {
      debugPrint('Error getting tile bytes for $tileKey: $e');
      rethrow;
    }
  }
}