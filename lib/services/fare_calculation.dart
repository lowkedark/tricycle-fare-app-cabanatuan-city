import "package:geolocator/geolocator.dart";

class FareCalculation {
  final int numberOfPassengers;
  final double baseFare;
  final double ratePerKm;
  final bool isDiscounted;

  double _totalDistance = 0.0;
  Position? _lastPosition;

  FareCalculation({
    required this.numberOfPassengers,
    required this.isDiscounted,
    this.baseFare = 0.0,
    this.ratePerKm = 0.0, // still required but recalculated internally
  });

  double _getEffectiveRate() {
    if (numberOfPassengers < 2) {
      return isDiscounted ? 15.0 : 20.0;
    } else {
      return isDiscounted ? 10.0 : 15.0;
    }
  }

  double updateWithNewPosition(Position newPosition) {
    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      _totalDistance += distance / 1000; // convert to km
    }
    _lastPosition = newPosition;
    return getCurrentFare();
  }

  double getCurrentFare() {
    return baseFare + (_totalDistance * _getEffectiveRate());
  }

  void reset() {
    _totalDistance = 0.0;
    _lastPosition = null;
  }

  double get totalDistance => _totalDistance;
}
