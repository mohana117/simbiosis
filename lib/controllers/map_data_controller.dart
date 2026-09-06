import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class MapDataController extends ChangeNotifier {
  List<OpenDataPoint> userListings = [];
  List<OpenDataPoint> apiPoints = [];
  List<PurchasedItem> purchasedItems = [];
  bool isLoading = false;

  List<OpenDataPoint> get openDataPoints => [...userListings, ...apiPoints];

  MapDataController() {
    initFastLoad();
  }

  Future<void> initFastLoad() async {
    await loadFromCache();
    fetchLiveOpenData();
  }

  void addListing(OpenDataPoint listing) {
    userListings.insert(0, listing);
    notifyListeners();
  }

  void addPurchase(PurchasedItem item, double purchasedTons) {
    purchasedItems.insert(0, item);

    for (var list in [userListings, apiPoints]) {
      final index = list.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        list[index].quantityTons -= purchasedTons;
        if (list[index].quantityTons < 0.5) {
          list.removeAt(index);
        }
        break;
      }
    }
    notifyListeners();
  }

  void completePurchase(int index) {
    if (index >= 0 && index < purchasedItems.length) {
      if (purchasedItems[index].status == 'In Progress') {
        purchasedItems[index].status = 'Completed';
        notifyListeners();
      }
    }
  }

  Future<void> fetchLiveOpenData() async {
    if (apiPoints.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    const overpassQuery = '''
      [out:json][timeout:35];
      area["ISO3166-1"="MY"]->.searchArea;
      (
        node["industrial"](area.searchArea);
        way["industrial"](area.searchArea);
        node["amenity"="recycling"](area.searchArea);
        way["amenity"="recycling"](area.searchArea);
        node["amenity"="waste_disposal"](area.searchArea);
        way["amenity"="waste_disposal"](area.searchArea);
        node["amenity"="waste_transfer_site"](area.searchArea);
        way["amenity"="waste_transfer_site"](area.searchArea);
        node["landfill"="yes"](area.searchArea);
        way["landfill"="yes"](area.searchArea);
        node["industrial"="scrap_yard"](area.searchArea);
        way["industrial"="scrap_yard"](area.searchArea);
      );
      out center;
    ''';

    final overpassUrl = Uri.parse('https://overpass-api.de/api/interpreter')
        .replace(queryParameters: {'data': overpassQuery});

    try {
      final response = await http.get(overpassUrl);
      if (response.statusCode == 200) {
        try {
          final List<OpenDataPoint> parsedPoints = parseOverpassJson(response.body);
          if (parsedPoints.isNotEmpty) {
            apiPoints = parsedPoints;
            saveToCache(response.body);
          } else {
            print('⚠️ No valid points found in OSM data');
          }
        } catch (e) {
          print('❌ Error parsing OSM JSON: $e');
          await loadFromCache();
        }
      } else {
        print('❌ OSM API returned status: ${response.statusCode}');
        await loadFromCache();
      }
    } catch (e) {
      print('❌ Network error fetching OSM data: $e');
      await loadFromCache();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedJson = prefs.getString('cached_map_hubs');
      if (cachedJson != null) {
        final List<OpenDataPoint> cachedPoints = parseOverpassJson(cachedJson);
        if (cachedPoints.isNotEmpty) {
          apiPoints = cachedPoints;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> saveToCache(String rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_map_hubs', rawJson);
  }
}

List<OpenDataPoint> parseOverpassJson(String rawBody) {
  try {
    final data = json.decode(rawBody);
    final List elements = data['elements'] ?? [];
    List<OpenDataPoint> points = [];

    final mockReps = [
      {'name': 'Ahmad Zaki', 'phone': '+60 12-345 6789'},
      {'name': 'Tan Wei Lun', 'phone': '+60 16-888 9912'},
      {'name': 'Suresh Kumar', 'phone': '+60 17-554 3210'},
      {'name': 'Siti Sarah', 'phone': '+60 19-223 4455'},
    ];

    for (var item in elements) {
      try {
        String id = 'unknown';
        if (item['id'] != null) {
          id = item['id'].toString();
        }

        final tags = item['tags'] ?? {};

        double? lat;
        double? lon;

        if (item['lat'] != null && item['lon'] != null) {
          if (item['lat'] is num && item['lon'] is num) {
            lat = (item['lat'] as num).toDouble();
            lon = (item['lon'] as num).toDouble();
          }
        } else if (item['center'] != null && item['center'] is Map) {
          final center = item['center'] as Map;
          if (center['lat'] != null && center['lon'] != null) {
            if (center['lat'] is num && center['lon'] is num) {
              lat = (center['lat'] as num).toDouble();
              lon = (center['lon'] as num).toDouble();
            }
          }
        }

        if (lat == null || lon == null) continue;
        if (lat == 0.0 && lon == 0.0) continue;

        int elementId = 0;
        if (item['id'] != null) {
          if (item['id'] is int) {
            elementId = item['id'] as int;
          } else if (item['id'] is String) {
            elementId = int.tryParse(item['id'] as String) ?? 0;
          }
        }

        final String state = getStateName(lat, lon);
        final String properTitle = getProperName(tags, state, elementId);

        final math.Random random = math.Random(elementId.abs());
        final double price = ((random.nextDouble() * 3.5) + 0.5);
        final double qty = ((random.nextInt(45) + 5).toDouble());
        final rep = mockReps[elementId.abs() % mockReps.length];

        points.add(
          OpenDataPoint(
            id: id,
            title: properTitle,
            latitude: lat,
            longitude: lon,
            sector: getSectorName(tags, properTitle, elementId),
            state: state,
            address: '$properTitle, $state, Malaysia',
            pricePerKg: double.parse(price.toStringAsFixed(2)),
            quantityTons: qty,
            repName: rep['name']!,
            repPhone: rep['phone']!,
            images: [],
          ),
        );
      } catch (e) {
        print('Skipping invalid OSM entry: $e');
        continue;
      }
    }
    return points;
  } catch (e) {
    print('Error parsing OSM data: $e');
    return [];
  }
}

String getProperName(Map tags, String state, int id) {
  try {
    final String? explicitName = tags['name']?.toString() ??
        tags['name:en']?.toString() ??
        tags['operator']?.toString();
    if (explicitName != null && explicitName.trim().isNotEmpty) {
      return explicitName.trim();
    }
  } catch (e) {
    // Fall through to default
  }
  return '$state Public Waste Hub';
}

String getSectorName(Map tags, String title, int id) {
  try {
    final String? sector = tags['industrial']?.toString() ??
        tags['recycling:type']?.toString() ??
        tags['landuse']?.toString();
    if (sector != null && sector.trim().isNotEmpty) {
      return sector.trim();
    }
  } catch (e) {
    // Fall through to default
  }

  final categories = ['Plastic', 'Metal', 'Cardboard', 'Textile', 'Glass', 'Organic', 'Electronics', 'Chemical', 'Paper', 'Rubber', 'Wood'];
  return categories[id.abs() % categories.length];
}

String getStateName(double lat, double lon) {
  if (lon > 109.0) {
    return lat > 4.5 ? 'Sabah' : 'Sarawak';
  }
  if (lat > 5.1) {
    return lon > 100.4 ? 'Kedah' : 'Penang';
  }
  if (lat > 6.4) {
    return 'Perlis';
  }
  if (lat > 5.0 && lon > 102.0) {
    return 'Kelantan';
  }
  if (lat > 4.5 && lon > 103.0) {
    return 'Terengganu';
  }
  if (lat > 3.4 && lon > 102.0) {
    return 'Pahang';
  }
  if (lat > 4.0 && lon < 101.5) {
    return 'Perak';
  }
  if (lat > 2.8 && lon < 102.0) {
    return 'Selangor';
  }
  if (lat > 3.0 && lon > 101.6 && lon < 101.8) {
    return 'W.P. Kuala Lumpur';
  }
  if (lat > 2.3 && lon < 102.3) {
    return 'Negeri Sembilan';
  }
  if (lat > 2.0 && lon < 102.5) {
    return 'Melaka';
  }
  if (lat < 2.0) {
    return 'Johor';
  }
  return 'Selangor';
}