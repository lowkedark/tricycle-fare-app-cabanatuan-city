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

  void _startTracking() async {
    try {
      await _fareStream.startRide();
      setState(() {
        _isTracking = true;
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
    setState(() {});
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
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(15.4865, 120.9665), // Default center
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                StreamBuilder<LatLng>(
                  stream: _fareStream.locationStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: snapshot.data!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          StreamBuilder<double>(
            stream: _fareStream.fareStreamed,
            builder: (context, snapshot) {
              final fare = snapshot.data ?? 0.0;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Current Fare: ₱${fare.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
