import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/recycling_center_model.dart';

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

final locatorProvider = NotifierProvider<LocatorNotifier, LocatorState>(() {
  return LocatorNotifier();
});

class LocatorNotifier extends Notifier<LocatorState> {
  @override
  LocatorState build() {
    // We can't call async items in build directly if we want initial state
    // But we can trigger them
    Future.microtask(() => refreshLocation());
    
    return LocatorState(
      latitude: 22.6948, // Default Nadiad
      longitude: 72.8631,
      centers: [],
    );
  }

  static const double defaultLat = 22.6948;
  static const double defaultLng = 72.8631;

  final List<RecyclingCenter> _mockCenters = [
    RecyclingCenter(name: "Nadiad Green Hub", latitude: 22.6948, longitude: 72.8631, category: "Plastic"),
    RecyclingCenter(name: "Kheda Recycling Point", latitude: 22.7533, longitude: 72.6865, category: "Organic"),
    RecyclingCenter(name: "Anand E-Waste Care", latitude: 22.5645, longitude: 72.9289, category: "E-Waste"),
    RecyclingCenter(name: "Vadtal Glass Center", latitude: 22.6105, longitude: 72.8835, category: "Glass"),
    RecyclingCenter(name: "Chakala Paper Depot", latitude: 22.6850, longitude: 72.8750, category: "Paper"),
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
        error = "Location services disabled. Using default (Nadiad).";
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            error = "Permission denied. Using default (Nadiad).";
          }
        }

        if (permission == LocationPermission.deniedForever) {
          error = "Permission denied forever. Using default (Nadiad).";
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
