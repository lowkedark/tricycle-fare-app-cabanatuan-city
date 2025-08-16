import "dart:async";
import "package:geolocator/geolocator.dart";
import "package:latlong2/latlong.dart";
import "fare_calculation.dart";
import "gps_tracker.dart";

class FareStream {
  final GpsTracker _gpsTracker = GpsTracker();
  late FareCalculation _fareCalculation;
  
  StreamSubscription<Position>? _gpsSubscription;

  final StreamController<double> _fareController = StreamController.broadcast();
  final StreamController<double> _distanceController = StreamController.broadcast();
  final StreamController<LatLng> _locationController = StreamController.broadcast();

  Stream<double> get fareStreamed => _fareController.stream;
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<LatLng> get locationStream => _locationController.stream;

  // constructor
  FareStream({
    double farePerKM = 20.0,
    double discountRate = 0.25,
    bool isDiscounted = false,
    int numberOfPassengers = 1,
    double baseFare = 0.0,
  }) {
    _fareCalculation = FareCalculation(
      farePerKM: farePerKM,
      discountRate: discountRate,
      isDiscounted: isDiscounted,
      numberOfPassengers: numberOfPassengers,
      baseFare: baseFare,
    );
  }

  Future<void> startRide() async {
    bool hasPermission = await _gpsTracker.checkAndRequestPermission();
    if (!hasPermission) {
      throw Exception("GPS Permission Denied");
    }

    _gpsSubscription = _gpsTracker.getPositionStream().listen((position) {
      double currentFare = _fareCalculation.updateWithNewPosition(position);

      _fareController.add(currentFare);
      _distanceController.add(_fareCalculation.totalDistance);
      _locationController.add(LatLng(position.latitude, position.longitude));
    });
  }

  void stopRide() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }

  void resetRide() {
    _fareCalculation.reset();
    _fareController.add(0.0);
    _distanceController.add(0.0);
  }

  void dispose() {
    _fareController.close();
    _distanceController.close();
    _locationController.close();
    stopRide();
  }
}
