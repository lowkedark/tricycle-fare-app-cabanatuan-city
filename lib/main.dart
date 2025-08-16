import 'package:flutter/material.dart';
import 'services/gps_tracker.dart';
import 'screens/test_main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyLauncherApp());
}

class MyLauncherApp extends StatefulWidget {
  const MyLauncherApp({super.key});

  @override
  State<MyLauncherApp> createState() => _MyLauncherAppState();
}

class _MyLauncherAppState extends State<MyLauncherApp> {
  final GpsTracker _gpsTracker = GpsTracker();
  bool _loading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool granted = await _gpsTracker.checkAndRequestPermission();
    setState(() {
      _hasPermission = granted;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!_hasPermission) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text("Location Permission Required")),
          body: Center(
            child: ElevatedButton(
              onPressed: _checkPermission,
              child: const Text("Grant Permission"),
            ),
          ),
        ),
      );
    }

    return MyTestApp(gpsTracker: _gpsTracker);
  }
}
