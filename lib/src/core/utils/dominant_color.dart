import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

class DominantColor {
  static List<Color> get(Uint8List bytes) {
    if (bytes.isEmpty) return [Colors.grey, Colors.grey];
    final dominantColors =
        _DominantColors(bytes: bytes, dominantColorsCount: 2).extractDominantColors();
    return dominantColors;
  }

  static Color getReverseWhiteOrBlack(Color color) {
    final luminance = color.computeLuminance();
    if (luminance > 0.179) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}

class _DominantColors {
  // We want to extract two dominant colors

  _DominantColors({required this.bytes, required this.dominantColorsCount});
  final Uint8List bytes;
  int dominantColorsCount = 1;

  // Calculate Euclidean distance between two colors
  double distance(Color a, Color b) =>
      sqrt(pow(a.red - b.red, 2) + pow(a.green - b.green, 2) + pow(a.blue - b.blue, 2));

  // Initialize centroids using K-means++
  List<Color> initializeCentroids(List<Color> colors) {
    final random = Random();
    final centroids = <Color>[colors[random.nextInt(10)]];

    for (var i = 1; i < dominantColorsCount; i++) {
      final distances = colors
          .map((color) => centroids.map((centroid) => distance(color, centroid)).reduce(min))
          .toList();

      final sum = distances.reduce((a, b) => a + b);
      final r = random.nextDouble() * sum;

      var accumulatedDistance = 0.0;
      for (var j = 0; j < colors.length; j++) {
        accumulatedDistance += distances[j];
        if (accumulatedDistance >= r) {
          centroids.add(colors[j]);
          break;
        }
      }
    }

    return centroids;
  }

  // Cluster colors using K-means++ and return centroids
  List<Color> extractDominantColors() {
    final colors = _getPixelsColorsFromHalfImage();
    final centroids = initializeCentroids(colors);
    var oldCentroids = <Color>[];

    while (_isConverging(centroids, oldCentroids)) {
      oldCentroids = List.from(centroids);
      final clusters = List<List<Color>>.generate(dominantColorsCount, (index) => []);

      for (var color in colors) {
        final closestIndex = _findClosestCentroid(color, centroids);
        clusters[closestIndex].add(color);
      }

      for (var i = 0; i < dominantColorsCount; i++) {
        centroids[i] = _averageColor(clusters[i]);
      }
    }

    return centroids;
  }

  List<Color> _getPixelsColorsFromHalfImage() {
    final colors = <Color>[];

    final image = imageLib.decodeImage(bytes.buffer.asUint8List());

    if (image != null) {
      var sampling = 5; //sampling, Adjust as needed. 5 means every 5th pixel, etc.

      final width = image.width;
      final height = image.height;
      if (width > 1300) {
        sampling = 10;
      }
      final heightTakenForColors =
          height / 2; //half of the image is always enough, compared to full image
      final widthTakenForColors = width / 2;

      for (var y = 0; y < heightTakenForColors; y += sampling) {
        for (var x = 0; x < widthTakenForColors; x += sampling) {
          final pixel = image.getPixel(x, y);

          // Extract the red, green, blue and alpha components from the pixel
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          final a = pixel.a.toInt();

          //Color color = Color.fromARGB(a, r, g, b);
          colors.add(Color.fromARGB(a, r, g, b));
        }
      }
    }

    return colors;
  }

  bool _isConverging(List<Color> centroids, List<Color> oldCentroids) {
    if (oldCentroids.isEmpty) return true;
    for (var i = 0; i < centroids.length; i++) {
      if (centroids[i] != oldCentroids[i]) return true;
    }
    return false;
  }

  int _findClosestCentroid(Color color, List<Color> centroids) {
    var minIndex = 0;
    var minDistance = distance(color, centroids[0]);
    for (var i = 1; i < centroids.length; i++) {
      final dist = distance(color, centroids[i]);
      if (dist < minDistance) {
        minDistance = dist;
        minIndex = i;
      }
    }
    return minIndex;
  }

  Color _averageColor(List<Color> colors) {
    int r = 0, g = 0, b = 0;
    for (var color in colors) {
      r += color.red;
      g += color.green;
      b += color.blue;
    }
    final length = colors.length;
    r = r ~/ length;
    g = g ~/ length;
    b = b ~/ length;
    return Color.fromRGBO(r, g, b, 1);
  }

  Future<Uint8List> fetchImage(String photoUrl) async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(photoUrl));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  }
}
