import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.lat, required this.lng});
  final double lat;
  final double lng;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(widget.lat, widget.lng),
            initialZoom: 16.5,
            
          ),
          children: [
            TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.spyder.rapidrescue',
              ),
            CircleLayer(circles: [
              CircleMarker(point: LatLng(widget.lat, widget.lng), radius: 10, color: Colors.red)
            ])
          ],
        ),
      ),
    );
  }
}
