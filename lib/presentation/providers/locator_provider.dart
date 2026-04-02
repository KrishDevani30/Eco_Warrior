import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/recycling_center_model.dart';

class LocatorState {
  final double latitude;
  final double longitude;
  final List<RecyclingCenter> centers;
  final bool isFetching;
  final bool isFallback;
  final String? errorMessage;

  LocatorState({
    required this.latitude,
    required this.longitude,
    required this.centers,
    this.isFetching = false,
    this.isFallback = false,
    this.errorMessage,
  });

  LocatorState copyWith({
    double? latitude,
    double? longitude,
    List<RecyclingCenter>? centers,
    bool? isFetching,
    bool? isFallback,
    String? errorMessage,
  }) {
    return LocatorState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      centers: centers ?? this.centers,
      isFetching: isFetching ?? this.isFetching,
      isFallback: isFallback ?? this.isFallback,
      errorMessage: errorMessage,
    );
  }
}

final locatorProvider = StateNotifierProvider<LocatorNotifier, LocatorState>((ref) {
  return LocatorNotifier();
});

class LocatorNotifier extends StateNotifier<LocatorState> {
  LocatorNotifier()
      : super(LocatorState(
          latitude: 19.0760, // Default Mumbai
          longitude: 72.8777,
          centers: [],
        )) {
    refreshLocation();
  }

  static const double defaultLat = 19.0760;
  static const double defaultLng = 72.8777;

  final List<RecyclingCenter> _mockCenters = [
    RecyclingCenter(name: "Mumbai Recycling Hub", latitude: 19.0760, longitude: 72.8777, category: "Plastic"),
    RecyclingCenter(name: "Eco Waste Center", latitude: 19.0820, longitude: 72.8810, category: "Organic"),
    RecyclingCenter(name: "E-Waste Drop Point", latitude: 19.0700, longitude: 72.8700, category: "E-Waste"),
    RecyclingCenter(name: "Glass Collection Point", latitude: 19.0900, longitude: 72.8850, category: "Glass"),
    RecyclingCenter(name: "Paper Recycling Center", latitude: 19.0650, longitude: 72.8650, category: "Paper"),
  ];

  Future<void> refreshLocation() async {
    state = state.copyWith(isFetching: true, errorMessage: null);

    double currentLat = defaultLat;
    double currentLng = defaultLng;
    bool usingFallback = true;
    String? error;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = "Location services disabled. Using default (Mumbai).";
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            error = "Permission denied. Using default (Mumbai).";
          }
        }

        if (permission == LocationPermission.deniedForever) {
          error = "Permission denied forever. Using default (Mumbai).";
        }

        if (error == null) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
          currentLat = position.latitude;
          currentLng = position.longitude;
          usingFallback = false;
        }
      }
    } catch (e) {
      error = "Unable to fetch location. Using default (Mumbai).";
    }

    // Calculate distances
    List<RecyclingCenter> centersWithDist = _mockCenters.map((center) {
      double distMeters = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        center.latitude,
        center.longitude,
      );
      return center.copyWith(distanceKm: distMeters / 1000);
    }).toList();

    // Sort by nearest
    centersWithDist.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    state = state.copyWith(
      latitude: currentLat,
      longitude: currentLng,
      centers: centersWithDist,
      isFetching: false,
      isFallback: usingFallback,
      errorMessage: error,
    );
  }
}
