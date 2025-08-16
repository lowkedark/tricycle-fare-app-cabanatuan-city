import "package:geolocator/geolocator.dart";

//initiate class with final elements for fare calculation
class FareCalculation {
  final double farePerKM;
  final double discountRate;
  final bool isDiscounted;
  final int numberOfPassengers;
  final double baseFare;
// track riders total distance riders and tells flutter doc that initial position stream can be null
  double _totalDistance = 0.0;
  Position? _lastPosition;
// default paramaters subject for change
  FareCalculation({
    this.farePerKM = 20.0,
    this.discountRate = 0.25,
    this.isDiscounted = false,
    this.numberOfPassengers = 1,
    this.baseFare = 0.0,
  });
//calculate and update the position stream of the user
  double updateWithNewPosition(Position newPosition) {
    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      // convert and add the current distance to the total distance
      _totalDistance += distance / 1000;
    }
    // set the flagged position as the new last position for .distanceBetween calculating
    _lastPosition = newPosition;
    // return current fare after distance update
    return getCurrentFare();
  }
// get basefare by multiplying with farePerKM
  double getCurrentFare() {
    double totalFare = baseFare + (_totalDistance * farePerKM);
// Discount price if student or other benefits are toggled
    if (isDiscounted) {
      totalFare *= (1 - discountRate);
    }
// distribute price equally to total number of passengers (subject for improvement)
    if (numberOfPassengers > 0) {
      totalFare /= numberOfPassengers;
    }

    return totalFare;
  }

  void reset() {
    _totalDistance = 0.0;
    _lastPosition = null;
  }
// allow other files to read total distance without the need to modify
  double get totalDistance => _totalDistance;
}