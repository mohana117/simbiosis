import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/map_data_controller.dart';
import '../models/data_models.dart';
import '../utils/helpers.dart';

class MapMarketplaceScreen extends StatefulWidget {
  final MapDataController dataController;
  const MapMarketplaceScreen({super.key, required this.dataController});

  @override
  State<MapMarketplaceScreen> createState() => MapMarketplaceScreenState();
}

class MapMarketplaceScreenState extends State<MapMarketplaceScreen> {
  final MapController mapController = MapController();
  String selectedCategory = 'All Waste';
  String selectedState = 'All States';
  double zoomLevel = 10.0;

  final List<String> categories = ['All Waste', 'Plastic', 'Metal', 'Cardboard', 'Textile', 'Glass', 'Organic', 'Electronics', 'Chemical', 'Paper', 'Rubber', 'Wood'];
  final List<String> malaysianStates = ['All States', 'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan', 'Pahang', 'Penang', 'Perak', 'Perlis', 'Sabah', 'Sarawak', 'Selangor', 'Terengganu', 'W.P. Kuala Lumpur'];

  @override
  void initState() {
    super.initState();
    widget.dataController.addListener(onDataUpdated);
  }

  @override
  void dispose() {
    widget.dataController.removeListener(onDataUpdated);
    super.dispose();
  }

  void onDataUpdated() {
    if (mounted) setState(() {});
  }

  void zoomIn() {
    setState(() {
      zoomLevel = math.min(zoomLevel + 1.0, 18.0);
      mapController.move(mapController.camera.center, zoomLevel);
    });
  }

  void zoomOut() {
    setState(() {
      zoomLevel = math.max(zoomLevel - 1.0, 3.0);
      mapController.move(mapController.camera.center, zoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPoints = widget.dataController.openDataPoints.where((point) {
      final matchesCategory = selectedCategory == 'All Waste' || point.sector == selectedCategory;
      final matchesState = selectedState == 'All States' || point.state == selectedState;
      return matchesCategory && matchesState;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFCBE3E7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      const Text('State:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F382C))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 38,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedState,
                              isExpanded: true,
                              items: malaysianStates.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedState = val!;
                                  if (selectedState != 'All States' && stateCoordinates.containsKey(selectedState)) {
                                    mapController.move(stateCoordinates[selectedState]!, 10.0);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F382C),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          onSelected: (selected) => setState(() => selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(3.0738, 101.5183),
                        initialZoom: zoomLevel,
                      ),
                      children: [
                        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                        MarkerLayer(
                          markers: filteredPoints.map((point) {
                            return Marker(
                              point: LatLng(point.latitude, point.longitude),
                              width: 100,
                              height: 60,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                    child: Text(point.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                  const Icon(Icons.location_on, color: Color(0xFF1CB026), size: 28),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.dataController.isLoading)
              const Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F382C)),
                  ),
                ),
              ),
            Positioned(
              right: 24,
              bottom: 24,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomInBtn',
                    backgroundColor: const Color(0xFF0F382C),
                    onPressed: zoomIn,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoomOutBtn',
                    backgroundColor: const Color(0xFF0F382C),
                    onPressed: zoomOut,
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}