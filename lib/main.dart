import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'services/fare_stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fare Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FareStream _fareStream = FareStream();
  bool _isTracking = false;

  // Fare controls
  int _passengers = 1;
  bool _isDiscounted = false;

  // Path polyline
  final List<LatLng> _pathPoints = [];

  void _startTracking() async {
    try {
      await _fareStream.startRide();
      setState(() {
        _isTracking = true;
        _pathPoints.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _stopTracking() {
    _fareStream.stopRide();
    setState(() {
      _isTracking = false;
    });
  }

  void _resetTracking() {
    _fareStream.resetRide();
    setState(() {
      _pathPoints.clear();
    });
  }

  void _updateFareRules() {
    _fareStream.updateFareRules(
      passengers: _passengers,
      discounted: _isDiscounted,
    );
  }

  @override
  void dispose() {
    _fareStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fare Tracker")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<LatLng>(
              stream: _fareStream.locationStream,
              builder: (context, snapshot) {
                final position = snapshot.data ??
                    const LatLng(15.4865, 120.9665); // Cabanatuan fallback

                // Append to path when new point arrives
                if (snapshot.hasData) {
                  _pathPoints.add(position);
                }

                return FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        const LatLng(15.4865, 120.9665), // Cabanatuan
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.debelen.fare_tracker',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _pathPoints,
                          strokeWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    if (snapshot.hasData)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: position,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),

          // Fare text
          StreamBuilder<double>(
            stream: _fareStream.fareStreamed,
            builder: (context, snapshot) {
              final fare = snapshot.data ?? 0.0;
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Current Fare: ₱${fare.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20),
                ),
              );
            },
          ),

          // Passenger slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Passengers:"),
                    Text("$_passengers"),
                  ],
                ),
                Slider(
                  value: _passengers.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: "$_passengers",
                  onChanged: (value) {
                    setState(() {
                      _passengers = value.toInt();
                      _updateFareRules();
                    });
                  },
                ),
              ],
            ),
          ),

          // Discount switch
          SwitchListTile(
            title: const Text("Discounted (Student / PWD)"),
            value: _isDiscounted,
            onChanged: (value) {
              setState(() {
                _isDiscounted = value;
                _updateFareRules();
              });
            },
          ),

          // Controls
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isTracking ? null : _startTracking,
                child: const Text("Start"),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _isTracking ? _stopTracking : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Stop"),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _resetTracking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
